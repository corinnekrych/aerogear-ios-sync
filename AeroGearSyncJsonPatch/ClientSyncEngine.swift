/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writtrrting, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/**
The ClientSyncEngine is responsible for driving client side of the [differential synchronization algorithm](http://research.google.com/pubs/pub35605.html).
During construction the engine gets injected with an instance of ClientSynchronizer
which takes care of diff/patching operations, and an instance of ClientDataStore for
storing data.
<br/><br/>
A synchronizer in AeroGear is a module that serves two purposes which are closely related. One, is to provide
storage for the data type, and the second is to provide the patching algorithm to be used on that data type.
The name synchronizer is because they take care of the synchronization part of the Differential Synchronization
algorithm. For example, one synchronizer, such as [DiffMatchPatchSynchronizer](https://github.com/aerogear/aerogear-ios-sync/blob/master/AeroGearSync-DiffMatchPatch/DiffMatchPatchSynchronizer.swift), might support plain text while another, such as [JsonPatchSynchronizer](https://github.com/aerogear/aerogear-ios-sync/blob/master/AeroGearSync-JSONPatch/JsonPatchSynchronizer.swift) supports JSON Objects as the
content of documents being stored. But a patching algorithm used for plain text might not be appropriate for JSON
Objects.
<br/><br/>
To construct a client that uses the JSON Patch you would use the following code:
<br/><br/>
```
var engine: ClientSyncEngine<JsonPatchSynchronizer, InMemoryDataStore<JsonNode, JsonPatchEdit>>
engine = ClientSyncEngine(synchronizer: JsonPatchSynchronizer(), dataStore: InMemoryDataStore())
```
<br/><br/>
The ClientSynchronizer generic type is the type that this implementation can handle.
The DataStore generic type is the type that this implementation can handle. 
The ClientSynchronizer and DataStore should have compatible document type.
*/
open class ClientSyncEngine<CS:ClientSynchronizer, D:DataStore> where CS.T == D.T, CS.D == D.D, CS.P.E == CS.D  {
    
    typealias T = CS.T
    typealias E = CS.D
    typealias P = CS.P
    
    /**
    The ClientSynchronizer in charge of providing the patching algorithm.
    */
    let synchronizer: CS
    
    /**
    The DataStore use for storing edits.
    */
    let dataStore: D
    
    /**
    The dictionary of callback closures.
    */
    var callbacks = Dictionary<String, (ClientDocument<T>) -> ()>()

    /**
    Default init.
    
    - parameter synchronizer: that this ClientSyncEngine will use.
    - parameter dataStore: that this ClientSyncEngine will use.
    */
    public init(synchronizer: CS, dataStore: D) {
        self.synchronizer = synchronizer
        self.dataStore = dataStore
    }

    /**
    Adds a new document to this sync engine.
    
    - parameter document: the document to add.
    */
    open func add(clientDocument: ClientDocument<T>, callback: @escaping (ClientDocument<T>) -> ()) {
        dataStore.save(clientDocument: clientDocument)
        let shadow = ShadowDocument(clientVersion: 0, serverVersion: 0, clientDocument: clientDocument)
        dataStore.save(shadowDocument: shadow)
        dataStore.save(backupShadowDocument: BackupShadowDocument(version: 0, shadowDocument: shadow))
        callbacks[clientDocument.id] = callback
    }

    /**
    Returns an PatchMessage of the type compatible with ClientSynchronizer (ie: eith DiffMatchPatchMessage or 
    JsonPatchMessage) which contains a diff against the engine's stored shadow document and the passed-in document.
    <br/><br/>
    There might be pending edits that represent edits that have not made it to the server
    for some reasons (for example packet drop). If a pending edit exits, the contents (ie: the diffs)
    of the pending edit will be included in the returned Edits from this method.
    <br/><br/>
    The returned PatchMessage instance is indended to be sent to the server engine
    for processing.
    
    - parameter document: the updated document.    
    - returns: PatchMessage containing the edits for the changes in the document.
    */

    open func diff(clientDocument: ClientDocument<T>) -> P? {
        if let shadow = dataStore.getShadowDocument(documentId: clientDocument.id, clientId: clientDocument.clientId) {
            let edit = diffAgainstShadow(clientDocument: clientDocument, shadow: shadow)
            dataStore.save(edit: edit)
            let patched = synchronizer.patchShadow(edit: edit, shadow: shadow)
            dataStore.save(shadowDocument: incrementClientVersion(shadow: patched))
            if let edits = dataStore.getEdits(documentId: clientDocument.id, clientId: clientDocument.clientId) {
                return synchronizer.createPatchMessage(id: clientDocument.id, clientId: clientDocument.clientId, edits: edits)
            }
        }
        return Optional.none
    }
    
    /**
    Patches the client side shadow with updates (PatchMessage) from the server.
    <br/><br/>
    When updates happen on the server, the server will create an PatchMessage instance
    by calling the server engines diff method. This PatchMessage instance will then be
    sent to the client for processing which is done by this method.
    
    - parameter patchMessage: the updates from the server.
    */
    open func patch(patchMessage: P) {
        if let patched = patchShadow(patchMessage: patchMessage) {
            let callback = callbacks[patchMessage.documentId!]!
            callback(patchDocument(shadow: patched)!)

            dataStore.save(backupShadowDocument: BackupShadowDocument(version: patched.clientVersion, shadowDocument: patched))
        }
    }

    fileprivate func patchShadow(patchMessage: P) -> ShadowDocument<T>? {
        if let edits = patchMessage.edits, let documentId = patchMessage.documentId, let clientId = patchMessage.clientId {
            if var shadow = dataStore.getShadowDocument(documentId: documentId, clientId: clientId) {
                for edit in edits {
                    if edit.serverVersion < shadow.serverVersion {
                        dataStore.remove(edit: edit)
                        continue
                    }
                    if (edit.clientVersion < shadow.clientVersion && !self.isSeedVersion(edit)) {
                        if let _ = restoreBackup(fromShadow: shadow, edit: edit) {
                            continue
                        }
                    }
                    if edit.serverVersion == shadow.serverVersion && edit.clientVersion == shadow.clientVersion || isSeedVersion(edit) {
                        let patched = synchronizer.patchShadow(edit: edit, shadow: shadow)
                        dataStore.remove(edit: edit)
                        if isSeedVersion(edit) {
                            shadow = save(shadow: seededShadowDocument(from: patched))
                        } else {
                            shadow = save(shadow: incrementServerVersion(shadow: patched))
                        }
                    }
                }
                return shadow
            }
        }
        return .none
    }

    fileprivate func seededShadowDocument(from: ShadowDocument<T>) -> ShadowDocument<T> {
        return ShadowDocument(clientVersion: 0, serverVersion: from.serverVersion, clientDocument: from.clientDocument)
    }

    fileprivate func incrementClientVersion(shadow: ShadowDocument<T>) -> ShadowDocument<T> {
        return ShadowDocument(clientVersion: shadow.clientVersion + 1, serverVersion: shadow.serverVersion, clientDocument: shadow.clientDocument)
    }

    fileprivate func incrementServerVersion(shadow: ShadowDocument<T>) -> ShadowDocument<T> {
        return ShadowDocument(clientVersion: shadow.clientVersion, serverVersion: shadow.serverVersion + 1, clientDocument: shadow.clientDocument)
    }

    fileprivate func save(shadow: ShadowDocument<T>) -> ShadowDocument<T> {
        dataStore.save(shadowDocument: shadow)
        return shadow
    }

    fileprivate func restoreBackup(fromShadow: ShadowDocument<T>, edit: E) -> ShadowDocument<T>? {
        if let backup = dataStore.getBackupShadowDocument(documentId: edit.documentId, clientId: edit.clientId) {
            if edit.clientVersion == backup.version {
                let patchedShadow = synchronizer.patchShadow(edit: edit, shadow: ShadowDocument(clientVersion: fromShadow.clientVersion, serverVersion: fromShadow.serverVersion, clientDocument: fromShadow.clientDocument))
                dataStore.removeEdits(documentId: edit.documentId, clientId: edit.clientId)
                dataStore.save(shadowDocument: patchedShadow)
                return patchedShadow
            }
        }
        return Optional.none
    }

    fileprivate func isSeedVersion(_ edit: E) -> Bool {
        return edit.clientVersion == -1
    }

    fileprivate func diffAgainstShadow(clientDocument: ClientDocument<T>, shadow: ShadowDocument<T>) -> E {
        return synchronizer.serverDiff(serverDocument: clientDocument, shadow: shadow)
    }

    fileprivate func patchDocument(shadow: ShadowDocument<T>) -> ClientDocument<T>? {
        if let document = dataStore.getClientDocument(documentId: shadow.clientDocument.id, clientId: shadow.clientDocument.clientId) {
            let edit = synchronizer.clientDiff(clientDocument: document, shadow: shadow)
            let patched = synchronizer.patchDocument(edit: edit, clientDocument: document)
            dataStore.save(clientDocument: patched)
            dataStore.save(backupShadowDocument: BackupShadowDocument(version: shadow.clientVersion, shadowDocument: shadow))
            return patched
        }
        return Optional.none
    }
    
    /**
    Delegate to Synchronizer.patchMessageFronJson. Creates a PatchMessage by parsing the passed-in json.
    
    - parameter json: string representation.
    - returns: PatchMessage created fron jsons string.
    */
    open func patchMessageFromJson(json: String) -> P? {
        return synchronizer.patchMessageFromJson(json: json)
    }
    /**
    Delegate to Synchronizer.addContent.
    - parameter clientDocument: the content itself.
    - returns: String with all ClientDocument information.
    */
    public func documentToJson(clientDocument:ClientDocument<T>) -> String {
        var str = "{\"msgType\":\"add\",\"id\":\"" + clientDocument.id + "\",\"clientId\":\"" + clientDocument.clientId + "\","
        synchronizer.add(content: clientDocument, fieldName: "content", objectNode: &str)
        str += "}"
        return str
    }
}

