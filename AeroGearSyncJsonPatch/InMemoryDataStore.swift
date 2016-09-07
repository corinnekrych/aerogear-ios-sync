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
An in-memory implementation of DataStore.
<br/><br/>
This implementation is mainly intended for testing and example applications.
<br/><br/>
```<T>``` the data type data that this implementation can handle.
<br/>
```<E>``` the type of Edits that this implementation can handle.
*/
public class InMemoryDataStore<T, E: Edit>: DataStore {
    
    private var documents = [Key: ClientDocument<T>]()
    private var shadows = [Key: ShadowDocument<T>]()
    private var backups = [Key: BackupShadowDocument<T>]()
    private var edits = [Key: [E]?]()
    
    /**
    Default init.
    */
    public init() {
    }
    
    /**
    Saves a client document.
    
    - parameter clientDocument: the ClientDocument to save.
    */
    public func saveClientDocument(document: ClientDocument<T>) {
        let key = InMemoryDataStore.key(document.id, document.clientId)
        documents[key] = document
    }

    /**
    Retrieves the ClientDocument matching the passed-in document documentId.
    
    - parameter documentId: the document id of the shadow document.
    - parameter clientId: the client for which to retrieve the shadow document.
    - returns:  ClientDocument the client document matching the documentId.
    */
    public func getClientDocument(documentId: String, clientId: String) -> ClientDocument<T>? {
        return documents[InMemoryDataStore.key(documentId, clientId)]
    }
    
    /**
    Saves a shadow document.
    
    - parameter shadowDocument: the ShadowDocument to save.
    */
    public func saveShadowDocument(shadow: ShadowDocument<T>) {
        let key = InMemoryDataStore.key(shadow.clientDocument.id, shadow.clientDocument.clientId)
        shadows[key] = shadow
    }
    
    /**
    Retrieves the ShadowDocument matching the passed-in document documentId.
    
    - parameter documentId: the document id of the shadow document.
    - parameter clientId: the client for which to retrieve the shadow document.
    - returns:  ShadowDocument the shadow document matching the documentId.
    */
    public func getShadowDocument(documentId: String, clientId: String) -> ShadowDocument<T>? {
        return shadows[InMemoryDataStore.key(documentId, clientId)]
    }
    
    /**
    Saves a backup shadow document.
    
    - parameter backupShadow: the BackupShadowDocument to save.
    */
    public func saveBackupShadowDocument(backup: BackupShadowDocument<T>) {
        let key = InMemoryDataStore.key(backup.shadowDocument.clientDocument.id, backup.shadowDocument.clientDocument.clientId)
        backups[key] = backup
    }
    
    /**
    Retrieves the BackupShadowDocument matching the passed-in document documentId.
    
    - parameter documentId: the document identifier of the backup shadow document.
    - parameter clientId: the client identifier for which to fetch the document.
    - returns: BackupShadowDocument the backup shadow document matching the documentId.
    */
    public func getBackupShadowDocument(documentId: String, clientId: String) -> BackupShadowDocument<T>? {
        return backups[InMemoryDataStore.key(documentId, clientId)]
    }
    
    /**
    Saves an Edit to the data store.
    
    - parameter edit: the edit to be saved.
    - parameter documentId: the document identifier for the edit.
    - parameter clientId: the client identifier for the edit.
    */
    public func saveEdits(edit: E) {
        let key = InMemoryDataStore.key(edit.documentId, edit.clientId)
        if var pendingEdits = self.edits[key] {
            pendingEdits!.append(edit)
            self.edits.updateValue(pendingEdits, forKey: key)
        } else {
            self.edits.updateValue([edit], forKey: key)
        }
    }
    
    /**
    Retreives the array of Edits for the specified document documentId.
    
    - parameter documentId: the document identifier of the edit.
    - parameter clientId: the client identifier for which to fetch the document.
    - returns: [D] the edits for the document.
    */
    public func getEdits(documentId: String, clientId: String) -> [E]? {
        if edits[InMemoryDataStore.key(documentId, clientId)] == nil {
            return nil
        } else {
            return edits[InMemoryDataStore.key(documentId, clientId)]!
        }
    }
    
    /**
    Removes the edit from the store.
    
    - parameter edit: the edit to be removed.
    - parameter documentId: the document identifier for the edit.
    - parameter clientId: the client identifier for the edit.
    */
    public func removeEdit(edit: E) {
        let key = InMemoryDataStore.key(edit.documentId, edit.clientId)
        if let pendingEdits = edits[key] {
            edits.updateValue(pendingEdits!.filter { edit.serverVersion != $0.serverVersion }, forKey: key)
        }
    }
    
    /**
    Removes all edits for the specific client and document pair.
    
    - parameter documentId: the document identifier of the edit.
    - parameter clientId: the client identifier.
    */
    public func removeEdits(documentId: String, clientId: String) {
        edits.removeValueForKey(Key(id: documentId, clientId: clientId))
    }

    private class func key(id: String, _ clientId: String) -> Key {
        return Key(id: id, clientId: clientId)
    }
    
}

func ==(lhs: Key, rhs: Key) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

/**
Key implement for Edit in DataStore.
*/
struct Key: Hashable {
    /**
    Edit id.
    */
    let id: String
    
    /**
    client id to identify client session.
    */
    let clientId: String
    
    /**
    Default init.
    
    - parameter id: of edit.
    - parameter clientId.:
    */
    init(id: String, clientId: String) {
        self.id = id
        self.clientId = clientId
    }
        
    var hashValue: Int {
        get {
            return "\(id),\(clientId)".hashValue
        }
    }
        
}
