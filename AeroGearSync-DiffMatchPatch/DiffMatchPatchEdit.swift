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
Represents a single edit that goes with DiffMatchPatch Synchronizer.
*/
public struct DiffMatchPatchEdit: Edit {
    /**
    The clientId to identifie which client it is related to.
    */
    public let clientId: String
    
    /**
    The documentId to identifie which docuemnt the edit applies to.
    */
    public let documentId: String
    
    /**
    The client version that edit is related to.
    */
    public let clientVersion: Int
    
    /**
    The server version that edit is related to.
    */
    public let serverVersion: Int
    
    /**
    A checksum of the opposing sides shadow document.
    The shadow document must patch strictly and this checksum is used to verify that the other sides
    shadow document is in fact the same. This can then be used by before patching to make sure that
    the shadow documents on both sides are in fact identical.
    */
    public let checksum: String
    
    /**
    The Diff for this edit.
    */
    public let diffs: [DiffMatchPatchDiff]
    
    /**
    Default init.
    
    - parameter clientId: represents an id of the client session.
    - parameter documentId: represents an id of the edit.
    - parameter clientVersion: represents the version of the client edit.
    - parameter serverVersion: represents an id of the server edit.
    - parameter checksum:
    - parameter diff: list of differences.
    */
    public init(clientId: String, documentId: String, clientVersion: Int, serverVersion: Int, checksum: String, diffs: [DiffMatchPatchDiff]) {
        self.clientId = clientId
        self.documentId = documentId
        self.clientVersion = clientVersion
        self.serverVersion = serverVersion
        self.checksum = checksum
        self.diffs = diffs
    }
    
    /**
    Printable protocol implementation, provides a string representation of the object.
    */
    public var description: String {
        return "DiffMatchPatchEdit[clientId=\(clientId), documentId=\(documentId), clientVersion=\(clientVersion), serverVersion=\(serverVersion), checksum=\(checksum), diffs=\(diffs)]"
    }
}

public func ==(lhs: DiffMatchPatchEdit, rhs: DiffMatchPatchEdit) -> Bool {
    return lhs.clientId == rhs.clientId &&
        lhs.documentId == rhs.documentId &&
        lhs.serverVersion == rhs.serverVersion &&
        lhs.checksum == rhs.checksum &&
        lhs.diffs.count == rhs.diffs.count
}

