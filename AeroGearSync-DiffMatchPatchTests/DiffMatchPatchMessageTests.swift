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

import UIKit
import XCTest
import AeroGearSync
import AeroGearSyncDiffMatchPatch

class DiffMatchPatchMessageTests: XCTestCase {
    
    var message: DiffMatchPatchMessage!
    var util: DocUtil!
    
    override func setUp() {
        super.setUp()
        let diff = DiffMatchPatchDiff(operation: DiffMatchPatchDiff.Operation.Add, text: "Hello")
        let edit = DiffMatchPatchEdit(clientId: "2", documentId: "1", clientVersion: 1, serverVersion: 2, checksum: "sum", diffs: [diff])
        self.message = DiffMatchPatchMessage(id: "1", clientId: "2", edits: [edit])
        self.util = DocUtil()
    }
    
    func testAsJson() {
        let shadowDoc = util.shadow("Do or do not, there is no try.")
        let serverDoc = util.document("Do or do not, there is no try!")
        
        let jsonString = message.asJson()
        
        XCTAssertEqual(jsonString, "{\"msgType\":\"patch\",\"id\":\"1\",\"clientId\":\"2\",\"edits\":[{\"clientVersion\":1,\"serverVersion\":2,\"checksum\":\"sum\",\"diffs\":[{\"operation\":\"ADD\",\"text\":\"Hello\"}]}]}");
    }
    
    func testFromJson() {
        let shadowDoc = util.shadow("Do or do not, there is no try.")
        let serverDoc = util.document("Do or do not, there is no try!")
        
        let jsonString = message.asJson()
        let json = message.fromJson(jsonString)
        
        XCTAssertEqual(json!.description, "DiffMatchPatchMessage[documentId=1, clientId=2, edits=[DiffMatchPatchEdit[clientId=2, documentId=1, clientVersion=1, serverVersion=2, checksum=sum, diffs=[DiffMatchPatchDiff[operation=ADD, text=Hello]]]]]");
    }
    
}