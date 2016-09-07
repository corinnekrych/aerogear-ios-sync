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
A DataStore implementation is responsible for storing and serving data for a
Differential Synchronization implementation.
<br/><br/>
```<T>``` the type of the Document that this data store can store.
<br/>
```<D>``` the type of Edits that this data store can store.
*/
public protocol DataStore {
    
    typealias T
    typealias D

    /**
    Saves a client document.
    
    - parameter clientDocument: the ClientDocument to save.
    */
    func saveClientDocument(clientDocument: ClientDocument<T>)
    
    /**
    Retrieves the ClientDocument matching the passed-in document documentId.
    
    - parameter documentId: the document id of the shadow document.
    - parameter clientId: the client for which to retrieve the shadow document.
    - returns: ClientDocument the client document matching the documentId.
    */
    func getClientDocument(documentId: String, clientId: String) -> ClientDocument<T>?
    
    /**
    Saves a shadow document.
    
    - parameter shadowDocument: the ShadowDocument to save.
    */
    func saveShadowDocument(shadowDocument: ShadowDocument<T>)
    
    /**
    Retrieves the ShadowDocument matching the passed-in document documentId.
    
    - parameter documentId: the document id of the shadow document.
    - parameter clientId: the client for which to retrieve the shadow document.
    - returns:  ShadowDocument the shadow document matching the documentId.
    */
    func getShadowDocument(documentId: String, clientId: String) -> ShadowDocument<T>?
    
    /**
    Saves a backup shadow document.
    
    - parameter backupShadow: the BackupShadowDocument to save.
    */
    func saveBackupShadowDocument(backupShadowDocument: BackupShadowDocument<T>)
    
    /**
    Retrieves the BackupShadowDocument matching the passed-in document documentId.
    
    - parameter documentId: the document identifier of the backup shadow document.
    - parameter clientId: the client identifier for which to fetch the document.
    - returns: BackupShadowDocument the backup shadow document matching the documentId.
    */
    func getBackupShadowDocument(documentId: String, clientId: String) -> BackupShadowDocument<T>?
    
    /**
    Saves an Edit to the data store.
    
    - parameter edit: the edit to be saved.
    - parameter documentId: the document identifier for the edit.
    - parameter clientId: the client identifier for the edit.
    */
    func saveEdits(edit: D)
    
    /**
    Retreives the array of Edits for the specified document documentId.
    
    - parameter documentId: the document identifier of the edit.
    - parameter clientId: the client identifier for which to fetch the document.
    - returns: [D] the edits for the document.
    */
    func getEdits(documentId: String, clientId: String) -> [D]?
    
    /**
    Removes the edit from the store.
    
    - parameter edit: the edit to be removed.
    - parameter documentId: the document identifier for the edit.
    - parameter clientId: the client identifier for the edit.
    */
    func removeEdit(edit: D)
    
    /**
    Removes all edits for the specific client and document pair.
    
    - parameter documentId: the document identifier of the edit.
    - parameter clientId: the client identifier.
    */
    func removeEdits(documentId: String, clientId: String)
    
}
