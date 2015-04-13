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
import AeroGearSyncJSONPatch

class JsonPatchSynchronizerTests: XCTestCase {
    
    var clientSynchronizer: JsonPatchSynchronizer!
    var util: DocUtil!
    
    override func setUp() {
        super.setUp()
        self.clientSynchronizer = JsonPatchSynchronizer()
        self.util = DocUtil()
    }
    
    func testClientDiffAddPatch() {
        var doc1:[String:AnyObject] = ["key1": "value1"]
        var doc2:[String:AnyObject] = ["key1": "value1", "key2": "value2"]
        let updated = util.document(doc1)
        let shadowDoc = util.shadow(doc2)
        let edit = clientSynchronizer.clientDiff(updated, shadow: shadowDoc)
        XCTAssertEqual(util.clientId, edit.clientId);
        XCTAssertEqual(util.documentId, edit.documentId);
        XCTAssertEqual(1, edit.diffs.count)
        XCTAssertEqual(JsonPatchDiff.Operation.Add, edit.diffs[0].operation)
        let value: AnyObject = edit.diffs[0].value!
        XCTAssertEqual("value2", value as! String)
    }
    
    func testClientDiffRemove() {
        var doc1:[String:AnyObject] = ["key1": "value1", "key2": "value2"]
        var doc2:[String:AnyObject] = ["key1": "value1"]
        let updated = util.document(doc1)
        let shadowDoc = util.shadow(doc2)
        let edit = clientSynchronizer.clientDiff(updated, shadow: shadowDoc)
        XCTAssertEqual(util.clientId, edit.clientId);
        XCTAssertEqual(util.documentId, edit.documentId);
        XCTAssertEqual(1, edit.diffs.count)
        XCTAssertEqual(JsonPatchDiff.Operation.Remove, edit.diffs[0].operation)
        XCTAssertEqual("/key2", edit.diffs[0].path)
        XCTAssertNil(edit.diffs[0].value)
    }
    
    func testClientDiffReplace() {
        var doc1:[String:AnyObject] = ["key1": "value1", "key2": ["key2.1": "value2.1"], "key3": "value3"]
        var doc2:[String:AnyObject] = ["key1": "value1", "key2": "value3", "key3": ["key2.1": "value2.1"]]
        let updated = util.document(doc1)
        let shadowDoc = util.shadow(doc2)
        let edit = clientSynchronizer.clientDiff(updated, shadow: shadowDoc)
        XCTAssertEqual(util.clientId, edit.clientId);
        XCTAssertEqual(util.documentId, edit.documentId);
        XCTAssertEqual(2, edit.diffs.count)
        let ops = edit.diffs.map {(op: $0.operation, path: $0.path, val: $0.value)}
        let sortedOps = ops.sorted {$0.1 < $1.1}
        XCTAssertEqual(JsonPatchDiff.Operation.Replace, sortedOps[1].op)
        XCTAssertEqual("/key3", sortedOps[1].path)
        let val: JsonNode = sortedOps[1].val! as! JsonNode
        XCTAssertTrue(val as NSObject == ["key2.1": "value2.1"])
    }
    
    func testClientDiffRemoveAdd() {
        var doc1:[String:AnyObject] = ["key1": "value1", "key2": ["key2.1": "value2.1"], "key3": "value3"]
        var doc2:[String:AnyObject] = ["key1": "value1", "key2": ["key2.1": "value2.1", "key3": "value3"]]
        let updated = util.document(doc1)
        let shadowDoc = util.shadow(doc2)
        let edit = clientSynchronizer.clientDiff(updated, shadow: shadowDoc)
        XCTAssertEqual(util.clientId, edit.clientId);
        XCTAssertEqual(util.documentId, edit.documentId);
        XCTAssertEqual(2, edit.diffs.count)
        let ops = edit.diffs.map {(op: $0.operation, path: $0.path, val: $0.value)}
        let sortedOps = ops.sorted {$0.0.rawValue < $1.0.rawValue}
        
        XCTAssertEqual(JsonPatchDiff.Operation.Remove, sortedOps[1].op)
        XCTAssertEqual("/key3", sortedOps[1].path)
        XCTAssertNil(sortedOps[1].val)
        XCTAssertEqual(JsonPatchDiff.Operation.Add, sortedOps[0].op)
        XCTAssertEqual("/key2/key3", sortedOps[0].path)
        let val = sortedOps[0].val! as! String
        XCTAssertTrue(val as NSObject == "value3")
    }
    
    func testServerDiff() {
        var doc1:[String:AnyObject] = ["key1": "value1"]
        var doc2:[String:AnyObject] = ["key1": "value1", "key2": "value2"]
        let shadowDoc = util.shadow(doc1)
        let serverDoc = util.document(doc2)
        let edit = clientSynchronizer.serverDiff(serverDoc, shadow: shadowDoc)
        XCTAssertEqual(util.clientId, edit.clientId);
        XCTAssertEqual(util.documentId, edit.documentId);
        XCTAssertEqual(1, edit.diffs.count)
        XCTAssertEqual(JsonPatchDiff.Operation.Add, edit.diffs[0].operation)
        XCTAssertEqual("/key2", edit.diffs[0].path)
        let value: AnyObject = edit.diffs[0].value!
        XCTAssertEqual("value2", value as! String)
    }
    
    func testPatchShadow() {
        var cientDoc:[String:AnyObject] = ["name": "fletch"]
        var sourceDoc:[String:AnyObject] = ["name": "Fletch", "firstname": "Robert"]
        let client = util.document(cientDoc)
        let source = util.shadow(sourceDoc)
        let edit = clientSynchronizer.serverDiff(client, shadow: source)
        
        let patchedDoc = clientSynchronizer.patchShadow(edit, shadow: source)
        
        XCTAssertEqual(util.clientId, edit.clientId);
        XCTAssertEqual(util.documentId, edit.documentId);
        XCTAssertEqual(2, edit.diffs.count)
        let content = patchedDoc.clientDocument.content as JsonNode
        XCTAssertEqual(content["name"] as! String, "fletch")
    }
    
    func testPatchDocumentWithAnAdd() {
        var doc1:[String:AnyObject] = ["name": "fletch"]
        var doc2:[String:AnyObject] = ["name": "Fletch", "firstname": "Robert"]
        let source = util.document(doc1)
        let updated = util.shadow(doc2)
        let edit = clientSynchronizer.clientDiff(source, shadow: updated)
        
        let patchedDoc = clientSynchronizer.patchDocument(edit, clientDocument: source)
        
        XCTAssertEqual(util.clientId, edit.clientId);
        XCTAssertEqual(util.documentId, edit.documentId);
        XCTAssertEqual(2, edit.diffs.count)
        XCTAssertEqual(patchedDoc.content["name"] as! String, "Fletch")
        XCTAssertEqual(patchedDoc.content["firstname"] as! String, "Robert")
    }
    
    func testPatchDocumentWithAnUpdateAddRemove() {
        var doc1:[String:AnyObject] = ["name": "fletch", "friends": [["name": "blanc", "firstname": "sebastien"], ["name": "Unkown", "firstname": "Bella"]]]
        var doc2:[String:AnyObject] = ["name": "Fletch", "firstname": "Robert", "friends": [["name": "Blanc", "firstname": "Sebastien"]]]
        let source = util.document(doc1)
        let updated = util.shadow(doc2)
        let edit = clientSynchronizer.clientDiff(source, shadow: updated)
        
        let patchedDoc = clientSynchronizer.patchDocument(edit, clientDocument: source)
        
        XCTAssertEqual(util.clientId, edit.clientId);
        XCTAssertEqual(util.documentId, edit.documentId);
        XCTAssertEqual(5, edit.diffs.count)
        XCTAssertEqual(patchedDoc.content["name"] as! String, "Fletch")
        XCTAssertEqual(patchedDoc.content["firstname"] as! String, "Robert")
        let friends = patchedDoc.content["friends"] as! [AnyObject]
        let friend = friends[0] as! JsonNode
        XCTAssertEqual(friend["firstname"] as! String, "Sebastien")
        XCTAssertEqual(friend["name"] as! String, "Blanc")
    }
    
}


