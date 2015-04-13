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
import DiffMatchPatch

/**
An instance of this class will be able to handle tasks needed to implement
Differential Synchronization for a text-based document.
*/
public class DiffMatchPatchSynchronizer: ClientSynchronizer {

    let dmp: DiffMatchPatch

    public init() {
        self.dmp = DiffMatchPatch()
    }
    
    /**
    Produces a Edit containing the changes between updated ShadowDocument and the ClientDocument.
    This method would be called when the client receives an update from the server and need
    to produce an Edit to be able to patch the ClientDocument.
    
    :param: shadowDocument the ShadowDocument patched with updates from the server
    :param: document the ClientDocument.
    :returns: Edit the edit representing the diff between the shadow document and the client document.
    */
    public func clientDiff(clientDocument: ClientDocument<String>, shadow: ShadowDocument<String>) -> DiffMatchPatchEdit {
        let diffs = dmp.diff_mainOfOldString(clientDocument.content, andNewString: shadow.clientDocument.content).copy() as! [Diff]
        return edit(shadow.clientDocument, shadow: shadow, diffs: diffs)
    }
    
    /**
    Called when the document should be patched.
    
    :param: edit the Edit containing the diffs/patches.
    :param: document the ClientDocument to be patched.
    :returns: ClientDocument a new patched document.
    */
    public func patchDocument(edit: DiffMatchPatchEdit, clientDocument: ClientDocument<String>) -> ClientDocument<String> {
        let results = dmp.patch_apply(patchesFrom(edit) as [AnyObject], toString: clientDocument.content)
        return ClientDocument<String>(id: clientDocument.id, clientId: clientDocument.clientId, content: results[0] as! String)
    }
    
    /**
    Called when the shadow should be patched. Is called when an update is recieved.
    
    :param: edit the Edit containing the diffs/patches.
    :param: shadowDocument the ShadowDocument to be patched.
    :returns: ShadowDocument a new patched shadow document.
    */
    public func patchShadow(edit: DiffMatchPatchEdit, shadow: ShadowDocument<String>) -> ShadowDocument<String> {
        return ShadowDocument(clientVersion: edit.clientVersion, serverVersion: shadow.serverVersion, clientDocument: patchDocument(edit, clientDocument: shadow.clientDocument))
    }
    
    /**
    Produces a Edit containing the changes between the updated ClientDocument
    and the ShadowDocument.
    <br/><br/>
    Calling the method is the first step in when starting a client side synchronization. We need to
    gather the changes between the updates made by the client and the shadow document.
    The produced Edit can then be passed to the server side.
    
    :param: document the ClientDocument containing updates made by the client.
    :param: shadowDocument the ShadowDocument for the ClientDocument.
    :returns: Edit the edit representing the diff between the client document and it's shadow document.
    */
    public func serverDiff(serverDocument: ClientDocument<String>, shadow: ShadowDocument<String>) -> DiffMatchPatchEdit {
        let diffs = dmp.diff_mainOfOldString(shadow.clientDocument.content, andNewString: serverDocument.content).copy() as! [Diff]
        return edit(shadow.clientDocument, shadow: shadow, diffs: diffs)
    }

    private func asDmpDiffs(diffs: [DiffMatchPatchDiff]) -> NSMutableArray {
        var dmpDiffs = NSMutableArray()
        for diff in diffs {
            dmpDiffs.addObject(Diff(operation: asDmpOperation(diff.operation), andText: diff.text))
        }
        return dmpDiffs
    }

    private func patchesFrom(edit: DiffMatchPatchEdit) -> NSArray {
        return dmp.patch_makeFromDiffs(asDmpDiffs(edit.diffs))
    }

    private func asDmpOperation(op: DiffMatchPatchDiff.Operation) -> Operation {
        switch op {
        case .Delete:
            return Operation.DiffDelete
        case .Add:
            return Operation.DiffInsert
        case .Unchanged:
            return Operation.DiffEqual
        }
    }

    private func asAeroGearDiffs(diffs: [Diff]) -> [DiffMatchPatchDiff] {
        return (diffs).map {
            DiffMatchPatchDiff(operation: DiffMatchPatchSynchronizer.asAeroGearOperation($0.operation), text: $0.text)
        }
    }

    private func edit(clientDoc: ClientDocument<String>, shadow: ShadowDocument<String>, diffs: [Diff]) -> DiffMatchPatchEdit {
        return DiffMatchPatchEdit(clientId: clientDoc.clientId, documentId: clientDoc.id, clientVersion: shadow.clientVersion, serverVersion: shadow.serverVersion, checksum: "", diffs: asAeroGearDiffs(diffs))
    }

    private class func asAeroGearOperation(op: Operation) -> DiffMatchPatchDiff.Operation {
        switch op {
        case .DiffDelete:
            return DiffMatchPatchDiff.Operation.Delete
        case .DiffInsert:
            return DiffMatchPatchDiff.Operation.Add
        case .DiffEqual:
            return DiffMatchPatchDiff.Operation.Unchanged
        }
    }
    
    /**
    Creates a PatchMessage by parsing the passed-in json.
    
    :param: json the json representation of a PatchMessage.
    :returns: PatchMessage the created PatchMessage.
    */
    public func patchMessageFromJson(json: String) -> DiffMatchPatchMessage? {
        return DiffMatchPatchMessage().fromJson(json)
    }
    
    /**
    Creates a new PatchMessage with the with the type of Edit that this
    synchronizer can handle.
    
    :param: documentId the document identifier for the PatchMessage.
    :param: clientId the client identifier for the PatchMessage.
    :param: edits the Edits for the PatchMessage.
    :returns: PatchMessage the created PatchMessage.
    */

    public func createPatchMessage(id: String, clientId: String, edits: [DiffMatchPatchEdit]) -> DiffMatchPatchMessage? {
        return DiffMatchPatchMessage(id: id, clientId: clientId, edits: edits)
    }
    
    /**
    Adds the content of the passed in content to the ObjectNode.
    <br/><br/>
    When a client initially adds a document to the engine it will also be sent across the
    wire to the server. Before sending, the content of the document has to be added to the
    JSON message payload. Different implementation will require different content types that
    the engine can handle and this give them control over how the content is added to the JSON
    string representation.
    <br/><br/>
    For example, a ClientEngine that stores simple text will just add the contents as a String,
    but one that stores JsonNode object will want to add its content as an object.
    
    :param: content the content to be added.
    :param: objectNode as a string to add the content to.
    :param: fieldName the name of the field.
    */
    public func addContent(clientDocument:ClientDocument<String>, fieldName:String, inout objectNode:String) {
        objectNode += "\"content\":\(clientDocument.content)"
    }
}
