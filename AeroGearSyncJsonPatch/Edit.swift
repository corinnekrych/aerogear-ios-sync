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
Represents a single edit. The typealias D refer to the type of the Diff comaptible with the Edit.
*/
public protocol Edit: Equatable, CustomStringConvertible {

    typealias D
    
    /**
    The clientId to identifie which client it is related to.
    */
    var clientId: String {get}
    
    /**
    The documentId to identifie which docuemnt the edit applies to.
    */
    var documentId: String {get}
    
    /**
    The client version that edit is related to.
    */
    var clientVersion: Int {get}
    
    /**
    The server version that edit is related to.
    */
    var serverVersion: Int {get}
    
    /**
    A checksum of the opposing sides shadow document.
    The shadow document must patch strictly and this checksum is used to verify that the other sides
    shadow document is in fact the same. This can then be used by before patching to make sure that
    the shadow documents on both sides are in fact identical.
    */
    var checksum: String {get}
    
    /**
    The Diff for this edit.
    */
    var diffs: [D] {get}
}


