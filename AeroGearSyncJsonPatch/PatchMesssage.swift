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
Represents a stack of changes made on the server of client side.
<br/><br/>
A PatchMessage is what is passed between the client and the server. It contains an array of
Edits that represent updates to be performed on the opposing sides document.
<br/><br/>
```<E>``` the type of the Edit that this PatchMessage holds.
*/
public protocol PatchMessage: CustomStringConvertible, Payload {
    
    associatedtype E: Edit
    
    /**
    Identifies the document that this edit is related to.
    */
    var documentId: String? {get}
    
    /**
    Identifies the client that this edit instance belongs to.
    */
    var clientId: String? {get}
    
    /**
    The list Edits.
    */
    var edits: [E]? {get}
    
    /**
    Default init.
    
    - parameter pathMessage: unique id.
    - parameter client: id to identify the client sesion.
    - parameter list: of edits that makes the content of the patch.
    */
    init(id: String, clientId: String, edits: [E])
}
