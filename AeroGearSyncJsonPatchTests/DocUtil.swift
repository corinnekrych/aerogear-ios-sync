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

import XCTest
import AeroGearSyncJsonPatch

class DocUtil {
    
    let documentId: String
    let clientId: String
    let content: String
    
    convenience init() {
        self.init(documentId: "1234", clientId: "client1", content: "something")
    }
    
    init(documentId: String, clientId: String, content: String) {
        self.clientId = clientId
        self.documentId = documentId
        self.content = content
    }
    
    func document() -> ClientDocument<String> {
        return ClientDocument(id: documentId, clientId: clientId, content: content)
    }
    
    func document<T>(_ content: T) -> ClientDocument<T> {
        return ClientDocument(id: documentId, clientId: clientId, content: content)
    }
    
    func shadow<T>(_ content: T) -> ShadowDocument<T> {
        return ShadowDocument(clientVersion: 0, serverVersion: 0, clientDocument: ClientDocument(id: documentId, clientId: clientId, content: content))
    }
    
    func shadow() -> ShadowDocument<String> {
        return ShadowDocument(clientVersion: 0, serverVersion: 0, clientDocument: ClientDocument(id: documentId, clientId: clientId, content: content))
    }
    
    func shadow<T>(_ doc: ClientDocument<T>) -> ShadowDocument<T> {
        return ShadowDocument(clientVersion: 0, serverVersion: 0, clientDocument: doc)
    }
    
    func backupShadow() -> BackupShadowDocument<String> {
        return BackupShadowDocument<String>(version: 1, shadowDocument: shadow())
    }
    
}
