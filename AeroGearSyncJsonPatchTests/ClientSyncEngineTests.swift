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


import XCTest
import AeroGearSyncJsonPatch

class ClientSyncEngineTests: XCTestCase {
    
    var clientSynchronizer: JsonPatchSynchronizer!
    var util: DocUtil!
    
    override func setUp() {
        super.setUp()
        self.clientSynchronizer = JsonPatchSynchronizer()
        self.util = DocUtil()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    public func testdocumentToJson() {
        let clientDocJson: JsonNode = ["name": "fletch"]
        let clientDoc = util.document(clientDocJson)
        let clientSyncEngine = ClientSyncEngine(synchronizer: clientSynchronizer, dataStore: InMemoryDataStore())
        let expectedResult = clientSyncEngine.documentToJson(clientDocument: clientDoc)
        
        XCTAssertEqual(expectedResult, "{\"msgType\":\"add\",\"id\":\"1234\",\"clientId\":\"client1\",\"content\":{\"name\":\"fletch\"}}")
    }
}
