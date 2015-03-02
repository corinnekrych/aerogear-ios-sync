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
Represents the server side version of a document.
<br/><br/>
```<T>``` the type of the document contents.
*/
public class Document<T>: Printable {
    
    /**
    The identifier for a document.
    */
    public let id: String
    
    /**
    The content for a document.
    */
    public let content: T
    
    /**
    Default init.
    
    :param: document id.
    :param: content of the document of generic type T.
    */
    init(id: String, content: T) {
        self.id = id
        self.content = content
    }
    
    /**
    Printable protocol implementation, provides a string representation of the object.
    */
    public var description: String {
        return "Document[id=\(id), content=\(content)]"
    }
    
}
