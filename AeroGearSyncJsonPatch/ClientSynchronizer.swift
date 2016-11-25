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
An instance of this class will be able to handle tasks needed to implement
Differential Synchronization for a specific type of documents.
<br/><br/>
```<T>``` the type of Documents that this synchronizer can handle
<br/>
```<D>``` the type of Edits that this synchronizer can handle
<br/>
```<P>``` the type of PatchMessage that this synchronizer can handle
*/
public protocol ClientSynchronizer {
    
    associatedtype T
    associatedtype D: Edit
    associatedtype P: PatchMessage
    
    /**
    Called when the shadow should be patched. Is called when an update is recieved.
    
    - parameter edit: the Edit containing the diffs/patches.
    - parameter shadowDocument: the ShadowDocument to be patched.
    - returns: ShadowDocument a new patched shadow document.
    */
    func patchShadow(_ edit: D, shadow: ShadowDocument<T>) -> ShadowDocument<T>
    
    /**
    Called when the document should be patched.
    
    - parameter edit: the Edit containing the diffs/patches.
    - parameter document: the ClientDocument to be patched.
    - returns: ClientDocument a new patched document.
    */
    func patchDocument(_ edit: D, clientDocument: ClientDocument<T>) -> ClientDocument<T>
    
    /**
    Produces a Edit containing the changes between updated ShadowDocument and the ClientDocument.
    This method would be called when the client receives an update from the server and need
    to produce an Edit to be able to patch the ClientDocument.
    
    - parameter shadowDocument: the ShadowDocument patched with updates from the server
    - parameter document: the ClientDocument.
    - returns: Edit the edit representing the diff between the shadow document and the client document.
    */
    func clientDiff(_ clientDocument: ClientDocument<T>, shadow: ShadowDocument<T>) -> D
    
    /**
    Produces a Edit containing the changes between the updated ClientDocument
    and the ShadowDocument.
    <br/><br/>
    Calling the method is the first step in when starting a client side synchronization. We need to
    gather the changes between the updates made by the client and the shadow document.
    The produced Edit can then be passed to the server side.
    
    - parameter document: the ClientDocument containing updates made by the client.
    - parameter shadowDocument: the ShadowDocument for the ClientDocument.
    - returns: Edit the edit representing the diff between the client document and it's shadow document.
    */
    func serverDiff(_ serverDocument: ClientDocument<T>, shadow: ShadowDocument<T>) -> D
    
    /**
    Creates a PatchMessage by parsing the passed-in json.
    
    - parameter json: the json representation of a PatchMessage.
    - returns: PatchMessage the created PatchMessage.
    */
    func patchMessageFromJson(_ json: String) -> P?
    
    /**
    Creates a new PatchMessage with the with the type of Edit that this
    synchronizer can handle.
    
    - parameter documentId: the document identifier for the PatchMessage.
    - parameter clientId: the client identifier for the PatchMessage.
    - parameter edits: the Edits for the PatchMessage.
    - returns: PatchMessage the created PatchMessage.
    */
    func createPatchMessage(_ id: String, clientId: String, edits: [D]) -> P?
    
    /**
    Adds the content of the passed in content to the ObjectNode.
    <br/><br/>
    When a client initially adds a document to the engine it will also be sent across the
    wire to the server. Before sending, the content of the document has to be added to the
    JSON message payload. Different implementation will require different content types that
    the engine can handle and this give them control over how the content is added to the JSON
    string representation.
    <br/><br/>
    For example, a ClientEngine that stores simple text will just add the contents as a String,
    but one that stores JsonNode object will want to add its content as an object.
    
    - parameter content: the content to be added.
    - parameter objectNode: as a string to add the content to.
    - parameter fieldName: the name of the field.
    */
    func addContent(_ content:ClientDocument<T>, fieldName:String, objectNode:inout String)
}
