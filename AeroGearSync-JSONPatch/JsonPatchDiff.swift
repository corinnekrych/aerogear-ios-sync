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

/**
A struct that represents a diff or two versions of a document/object.
*/
public struct JsonPatchDiff: Difference {
    
    /**
    Defines type of operation: Add, Remove etc...
    */
    public let operation: Operation
    
    /**
    Defines the path where the patch should be applied.
    */
    public let path: String
    
    /**
    Represents the content of the difference.
    */
    public let value: AnyObject?
    
    public enum Operation : String, CustomStringConvertible {
        case Add = "add"
        case Copy = "copy"
        case Remove = "remove"
        case Move = "move"
        case Replace = "replace"
        case Test = "test"
        // not in spec! it seems to be a hack in JSONTools to get back patched document
        case Get = "_get"
        public var description : String {
            return self.rawValue
        }
    }
    
    /**
    Default init.
    
    - parameter operation: either Add. copy, Replace...
    - parameter path: in the JSON document on where to apply the patch.
    - parameter value: the new JSON node. Could be nil for Remove.
    */
    public init(operation: Operation, path: String, value: AnyObject?) {
        self.operation = operation
        self.path = path
        self.value = value
    }
    
    /**
    Convenience init.
    
    - parameter operation: used got Get operation only.
    */
    public init(operation: Operation) {
        self.operation = operation
        self.path = ""
        self.value = nil
    }
    
    /**
    Printable protocol implementation, provides a string representation of the object.
    */
    public var description: String {
        return "JsonPatchDiff[operation=\(operation), path=\(path) value=\(value)]"
    }
}