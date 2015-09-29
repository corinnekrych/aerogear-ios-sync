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
import AeroGearSyncJSONPatch

class JsonPatchMessageTests: XCTestCase {
    
    var message: JsonPatchMessage!
    var util: DocUtil!
    
    override func setUp() {
        super.setUp()
        self.util = DocUtil()
        let doc1:[String:AnyObject] = ["key1": "value1"]
        let doc2:[String:AnyObject] = ["key1": "value1", "key2": "value2"]
        let updated = util.document(doc1)
        let shadowDoc = util.shadow(doc2)
        let clientSynchronizer = JsonPatchSynchronizer()
        let edit = clientSynchronizer.clientDiff(updated, shadow: shadowDoc)
        message = JsonPatchMessage(id: "1", clientId: "2", edits: [edit])        
    }
    
    func testAsJsonAndFromJson() {
        let jsonString = self.message.asJson()
        let obj = message.fromJson(jsonString)!
        XCTAssertEqual("2", obj.clientId)
        XCTAssertEqual("1", obj.documentId)
        XCTAssertEqual("2", obj.clientId)
        XCTAssertEqual(1, obj.edits.count)
        XCTAssertEqual(1, obj.edits[0].diffs.count)
        XCTAssertEqual(obj.description, "JsonPatchMessage[documentId=1, clientId=2, edits=[JsonPatchEdit[clientId=2, documentId=1, clientVersion=0, serverVersion=0, checksum=, diffs=[JsonPatchDiff[operation=add, path=/key2 value=Optional(value2)]]]]]");
    }
}