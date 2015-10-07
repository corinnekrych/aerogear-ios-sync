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
import AeroGearSyncDiffMatchPatch

class InMemoryDataStoreTests: XCTestCase {

    var documentId, clientId, content: String!
    var dataStore: InMemoryDataStore<String, DiffMatchPatchEdit>!
    var util: DocUtil!

    override func setUp() {
        super.setUp()
        dataStore = InMemoryDataStore<String, DiffMatchPatchEdit>();
        util = DocUtil();
    }

    func testSaveClientDocument() {
        dataStore.saveClientDocument(util.document())
        let clientDocument = dataStore.getClientDocument(util.documentId, clientId: util.clientId)!
        assertDefaultClientDocument(clientDocument)
    }

    func testSaveShadowDocument() {
        dataStore.saveShadowDocument(util.shadow())
        let shadow = dataStore.getShadowDocument(util.documentId, clientId: util.clientId)!
        assertDefaultShadow(shadow)
    }

    func testSaveBackupShadow() {
        dataStore.saveBackupShadowDocument(util.backupShadow())
        let backup = dataStore.getBackupShadowDocument(util.documentId, clientId: util.clientId)!
        XCTAssertEqual(1, backup.version)
        assertDefaultShadow(backup.shadowDocument)
    }
    
    func testSaveEdits() {
        let edit1 = defaultEdit(clientVersion: 1, serverVersion: 1)
        dataStore.saveEdits(edit1)
        XCTAssertEqual(1, dataStore.getEdits(util.documentId, clientId: util.clientId)!.count)
        let edit2 = defaultEdit(clientVersion: 2, serverVersion: 1)
        dataStore.saveEdits(edit2)
        XCTAssertEqual(2, dataStore.getEdits(util.documentId, clientId: util.clientId)!.count)
    }

    func testRemoveEdit() {
        let edit1 = defaultEdit(clientVersion: 0, serverVersion: 0)
        let edit2 = defaultEdit(clientVersion: 1, serverVersion: 1)
        dataStore.saveEdits(edit1)
        dataStore.saveEdits(edit2)
        dataStore.removeEdit(edit1)
        let savedEdits = dataStore.getEdits(util.documentId, clientId: util.clientId)!
        XCTAssertEqual(1, savedEdits.count)
        XCTAssertEqual(1, savedEdits[0].clientVersion)
        XCTAssertEqual(1, savedEdits[0].serverVersion)
        dataStore.removeEdit(edit2)
        XCTAssertEqual(0, dataStore.getEdits(util.documentId, clientId: util.clientId)!.count)
    }

    func testRemoveEdits() {
        dataStore.saveEdits(defaultEdit(clientVersion: 1, serverVersion: 1))
        dataStore.saveEdits(defaultEdit(clientVersion: 2, serverVersion: 1))
        dataStore.saveEdits(defaultEdit(clientVersion: 3, serverVersion: 1))
        dataStore.removeEdits(util.documentId, clientId: util.clientId)
        let edits: Optional<[DiffMatchPatchEdit]> = dataStore.getEdits(util.documentId, clientId: util.clientId)
        XCTAssertTrue(edits == nil)
    }

    func assertDefaultShadow(shadow: ShadowDocument<String>) {
        XCTAssertEqual(0, shadow.clientVersion)
        XCTAssertEqual(0, shadow.serverVersion)
        assertDefaultClientDocument(shadow.clientDocument)
    }

    func assertDefaultClientDocument(clientDocument: ClientDocument<String>) {
        XCTAssertEqual(util.documentId , clientDocument.id)
        XCTAssertEqual(util.clientId, clientDocument.clientId)
        XCTAssertEqual(util.content, clientDocument.content)
    }

    func defaultEdit(clientVersion  clientVersion: Int, serverVersion: Int) -> DiffMatchPatchEdit {
        return DiffMatchPatchEdit(clientId: util.clientId,
            documentId: util.documentId,
            clientVersion: clientVersion,
            serverVersion: serverVersion,
            checksum: "",
            diffs: [])
    }
}
