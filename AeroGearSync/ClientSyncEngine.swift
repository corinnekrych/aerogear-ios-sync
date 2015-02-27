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
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/**
The client side implementation of a Differential Synchronization Engine.
*/
public class ClientSyncEngine<CS:ClientSynchronizer, D:DataStore where CS.T == D.T, CS.D == D.D, CS.P.E == CS.D > {
    
    typealias T = CS.T
    typealias E = CS.D
    typealias P = CS.P
    let synchronizer: CS
    let dataStore: D
    var callbacks = Dictionary<String, (ClientDocument<T>) -> ()>()

    public init(synchronizer: CS, dataStore: D) {
        self.synchronizer = synchronizer
        self.dataStore = dataStore
    }

    public func addDocument(clientDocument: ClientDocument<T>, callback: ClientDocument<T> -> ()) {
        dataStore.saveClientDocument(clientDocument)
        let shadow = ShadowDocument(clientVersion: 0, serverVersion: 0, clientDocument: clientDocument)
        dataStore.saveShadowDocument(shadow)
        dataStore.saveBackupShadowDocument(BackupShadowDocument(version: 0, shadowDocument: shadow))
        callbacks[clientDocument.id] = callback
    }

    public func diff(clientDocument: ClientDocument<T>) -> P? {
        if let shadow = dataStore.getShadowDocument(clientDocument.id, clientId: clientDocument.clientId) {
            let edit = diffAgainstShadow(clientDocument, shadow: shadow)
            dataStore.saveEdits(edit)
            let patched = synchronizer.patchShadow(edit, shadow: shadow)
            dataStore.saveShadowDocument(incrementClientVersion(patched))
            let edits = dataStore.getEdits(clientDocument.id, clientId: clientDocument.clientId)

            return synchronizer.createPatchMessage(clientDocument.id, clientId: clientDocument.clientId, edits: edits!)
        }
        return Optional.None
    }

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
                    shadow = restoreBackup(shadow, edit: edit)!
                    continue
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
    
    public func patchMessageFromJson(json: String) -> P? {
        return synchronizer.patchMessageFromJson(json)
    }

    public func documentToJson(clientDocument:ClientDocument<T>) -> String {
        var str = "{\"msgType\":\"add\",\"id\":\"" + clientDocument.id + "\",\"clientId\":\"" + clientDocument.clientId + "\","
        synchronizer.addContent(clientDocument, fieldName: "content", objectNode: &str)
        str += "}"
        return str
    }
}

