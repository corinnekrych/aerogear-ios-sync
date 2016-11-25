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
A client document is used on both the server and client side and
associates a client identifier with a Document.
<br/><br/>
```<T>``` the type of this documents content.
*/
open class ClientDocument<T>: Document<T> {
    
    /**
    Identifies a client or session to which this Document belongs.
    */
    open let clientId: String
    
    /**
    Default init.
    
    - parameter id: of the document.
    - parameter clientId: or session to which this Document belongs.
    - parameter content: of the document.
    */
    public init(id: String, clientId: String, content: T) {
        self.clientId = clientId
        super.init(id: id, content: content)
    }
    
    /**
    Printable protocol implementation, provides a string representation of the object.
    */
    open override var description: String {
        return "ClientDocument[clientId=\(clientId), documentId=\(super.id), content=\(super.content)]"
    }
    
}
