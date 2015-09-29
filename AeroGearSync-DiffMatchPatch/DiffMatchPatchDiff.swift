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

import AeroGearSync

/**
Implements the marker interface that represents a diff or two versions of a document/object.
*/
public struct DiffMatchPatchDiff: Difference {
    
    /**
    Defines type of operation: ADD, DELETe, UNCHANGED.
    */
    public let operation: Operation
    
    /**
    Represents the content of the difference.
    */
    public let text: String
    
    public enum Operation : String, CustomStringConvertible {
        case Add = "ADD"
        case Delete = "DELETE"
        case Unchanged = "UNCHANGED"
        public var description : String {
            return self.rawValue
        }
    }
    
    /**
    Default init.
    
    - parameter operation: either ADD, DELETE, UNCHANGED.
    - parameter text: the content of the diff itself.
    */
    public init(operation: Operation, text: String) {
        self.operation = operation
        self.text = text
    }
    
    /**
    Printable protocol implementation, provides a string representation of the object.
    */
    public var description: String {
        return "DiffMatchPatchDiff[operation=\(operation), text=\(text)]"
    }
}