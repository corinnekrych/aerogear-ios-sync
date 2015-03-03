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
The ClientSyncEngine is responsible for driving client side of the [differential synchronization algorithm]().
During construction the engine gets injected with an instance of ClientSynchronizer
which takes care of diff/patching operations, and an instance of ClientDataStore for
storing data.
<br/><br/>
A synchronizer in AeroGear is a module that serves two purposes which are closely related. One, is to provide
storage for the data type, and the second is to provide the patching algorithm to be used on that data type.
The name synchronizer is because they take care of the synchronization part of the Differential Synchronization
algorithm. For example, one synchronizer might support plain text while another supports JSON Objects as the
content of documents being stored. But a patching algorithm used for plain text might not be appropriate for JSON
Objects.
<br/><br/>
To construct a client that uses the JSON Patch you would use the following code:
<br/><br/>
```var engine: ClientSyncEngine<JsonPatchSynchronizer, InMemoryDataStore<JsonNode, JsonPatchEdit>>
engine = ClientSyncEngine(synchronizer: JsonPatchSynchronizer(), dataStore: InMemoryDataStore())```
<br/><br/>
The ClientSynchronizer generic type is the type that this implementation can handle.
The DataStore generic type is the type that this implementation can handle. 
The ClientSynchronizer and DataStore should have compatible document type.
*/
public class ClientSyncEngine<CS:ClientSynchronizer, D:DataStore where CS.T == D.T, CS.D == D.D, CS.P.E == CS.D > {
    
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
    
    :param: synchronizer that this ClientSyncEngine will use.
    :param: dataStore that this ClientSyncEngine will use.
    */
    public init(synchronizer: CS, dataStore: D) {
        self.synchronizer = synchronizer
        self.dataStore = dataStore
    }

    /**
    Adds a new document to this sync engine.
    
    :param: document the document to add.
    */
    public func addDocument(clientDocument: ClientDocument<T>, callback: ClientDocument<T> -> ()) {
        dataStore.saveClientDocument(clientDocument)
        let shadow = ShadowDocument(clientVersion: 0, serverVersion: 0, clientDocument: clientDocument)
        dataStore.saveShadowDocument(shadow)
        dataStore.saveBackupShadowDocument(BackupShadowDocument(version: 0, shadowDocument: shadow))
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
    
    :param: document the updated document.    
    :returns: PatchMessage containing the edits for the changes in the document.
    */

    public func diff(clientDocument: ClientDocument<T>) -> P? {
        if let shadow = dataStore.getShadowDocument(clientDocument.id, clientId: clientDocument.clientId) {
            let edit = diffAgainstShadow(clientDocument, shadow: shadow)
            dataStore.saveEdits(edit)
            let patched = synchronizer.patchShadow(edit, shadow: shadow)
            dataStore.saveShadowDocument(incrementClientVersion(patched))
            if let edits = dataStore.getEdits(clientDocument.id, clientId: clientDocument.clientId) {
                return synchronizer.createPatchMessage(clientDocument.id, clientId: clientDocument.clientId, edits: edits)
            }
        }
        return Optional.None
    }
    
    /**
    Patches the client side shadow with updates (PatchMessage) from the server.
    <br/><br/>
    When updates happen on the server, the server will create an PatchMessage instance
    by calling the server engines diff method. This PatchMessage instance will then be
    sent to the client for processing which is done by this method.
    
    :param: patchMessage the updates from the server.
    */
    public func patch(patchMessage: P) {
        if let patched = patchShadow(patchMessage) {
            let callback = callbacks[patchMessage.documentId]!
            callback(patchDocument(patched)!)

            dataStore.saveBackupShadowDocument(BackupShadowDocument(version: patched.clientVersion, shadowDocument: patched))
        }
    }

    private func patchShadow(patchMessage: P) -> ShadowDocument<T>? {
        if var shadow = dataStore.getShadowDocument(patchMessage.documentId, clientId: patchMessage.clientId) {
            for edit in patchMessage.edits {
                if edit.serverVersion < shadow.serverVersion {
                    dataStore.removeEdit(edit)
                    continue
                }
                if (edit.clientVersion < shadow.clientVersion && !self.isSeedVersion(edit)) {
                    if let shadow = restoreBackup(shadow, edit: edit) {
                        continue
                    }
                }
                if edit.serverVersion == shadow.serverVersion && edit.clientVersion == shadow.clientVersion || isSeedVersion(edit) {
                    let patched = synchronizer.patchShadow(edit, shadow: shadow)
                    dataStore.removeEdit(edit)
                    if isSeedVersion(edit) {
                        shadow = saveShadow(seededShadowDocument(patched))
                    } else {
                        shadow = saveShadow(incrementServerVersion(patched))
                    }
                }
            }
            return shadow
        }
        return Optional.None
    }

    private func seededShadowDocument(from: ShadowDocument<T>) -> ShadowDocument<T> {
        return ShadowDocument(clientVersion: 0, serverVersion: from.serverVersion, clientDocument: from.clientDocument)
    }

    private func incrementClientVersion(shadow: ShadowDocument<T>) -> ShadowDocument<T> {
        return ShadowDocument(clientVersion: shadow.clientVersion + 1, serverVersion: shadow.serverVersion, clientDocument: shadow.clientDocument)
    }

    private func incrementServerVersion(shadow: ShadowDocument<T>) -> ShadowDocument<T> {
        return ShadowDocument(clientVersion: shadow.clientVersion, serverVersion: shadow.serverVersion + 1, clientDocument: shadow.clientDocument)
    }

    private func saveShadow(shadow: ShadowDocument<T>) -> ShadowDocument<T> {
        dataStore.saveShadowDocument(shadow)
        return shadow
    }

    private func restoreBackup(shadow: ShadowDocument<T>, edit: E) -> ShadowDocument<T>? {
        if let backup = dataStore.getBackupShadowDocument(edit.documentId, clientId: edit.clientId) {
            if edit.clientVersion == backup.version {
                let patchedShadow = synchronizer.patchShadow(edit, shadow: ShadowDocument(clientVersion: shadow.clientVersion, serverVersion: shadow.serverVersion, clientDocument: shadow.clientDocument))
                dataStore.removeEdits(edit.documentId, clientId: edit.clientId)
                dataStore.saveShadowDocument(patchedShadow)
                return patchedShadow
            }
        }
        return Optional.None
    }

    private func isSeedVersion(edit: E) -> Bool {
        return edit.clientVersion == -1
    }

    private func diffAgainstShadow(clientDocument: ClientDocument<T>, shadow: ShadowDocument<T>) -> E {
        return synchronizer.serverDiff(clientDocument, shadow: shadow)
    }

    private func patchDocument(shadow: ShadowDocument<T>) -> ClientDocument<T>? {
        if let document = dataStore.getClientDocument(shadow.clientDocument.id, clientId: shadow.clientDocument.clientId) {
            let edit = synchronizer.clientDiff(document, shadow: shadow)
            let patched = synchronizer.patchDocument(edit, clientDocument: document)
            dataStore.saveClientDocument(patched)
            dataStore.saveBackupShadowDocument(BackupShadowDocument(version: shadow.clientVersion, shadowDocument: shadow))
            return patched
        }
        return Optional.None
    }
    
    /**
    Delegate to Synchronizer.patchMessageFronJson. Creates a PatchMessage by parsing the passed-in json.
    
    :param: json string representation.
    :returns: PatchMessage created fron jsons string.
    */
    public func patchMessageFromJson(json: String) -> P? {
        return synchronizer.patchMessageFromJson(json)
    }
    
    /**
    Delegate to Synchronizer.addContent.
    
    :param: clientDocument the content itself.
    :returns: String with all ClientDocument information.
    */
    public func documentToJson(clientDocument:ClientDocument<T>) -> String {
        var str = "{\"msgType\":\"add\",\"id\":\"" + clientDocument.id + "\",\"clientId\":\"" + clientDocument.clientId + "\","
        synchronizer.addContent(clientDocument, fieldName: "content", objectNode: &str)
        str += "}"
        return str
    }
}

