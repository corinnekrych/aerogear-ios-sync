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
Represents something that can be exchanged in JSON format.
<br/><br/>
```<T>``` the type of the payload.
*/
public protocol Payload {
    
    associatedtype T
    
    /**
    Transforms this payload to a JSON String representation.
    - returns: s string representation of JSON object.
    */
    func asJson() -> String
    
    /**
    Transforms the passed in string JSON representation into this payloads type.
    
    - parameter json: a string representation of this payloads type.
    - returns: T an instance of this payloads type.
    */
    func asPayload(json:String) -> T?
}
