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
A shadow document for each client will exist on the client side and also on the server side.
<br/>
A shadow document is updated after a successful patch has been performed.
<br/><br/>
```<T>``` the type of the Document that this instance shadows.
*/
open class ShadowDocument<T>: CustomStringConvertible {
    /**
    Represents the latest client version that this shadow document was based on.
    */
    open let clientVersion: Int
    
    /**
    Represents the latest server version that the this shadow document was based on.
    */
    open let serverVersion: Int
    
    /**
    The document itself.
    */
    open let clientDocument: ClientDocument<T>
    
    /**
    Default init.
    
    - parameter clientVersion: he latest client version that this shadow document was based on.
    - parameter serverVersion: the latest server version that the this shadow document was based on.
    - parameter clientDocument.:
    */
    public init(clientVersion: Int, serverVersion: Int, clientDocument: ClientDocument<T>) {
        self.clientVersion = clientVersion
        self.serverVersion = serverVersion
        self.clientDocument = clientDocument
    }
    
    /**
    Printable protocol implementation, provides a string representation of the object.
    */
    open var description: String {
        return "ShadowDocument[clientVersion=\(clientVersion), serverVersion=\(serverVersion), clientDocument=\(clientDocument)]"
    }
}
