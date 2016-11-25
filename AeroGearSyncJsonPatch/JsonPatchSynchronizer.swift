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

import JSONTools

public typealias JsonNode = [String: Any]

/**
An instance of this class will be able to handle tasks needed to implement
Differential Synchronization for a Json document.
*/
open class JsonPatchSynchronizer: ClientSynchronizer {
    
    public init() {}
    
    /**
    Produces a Edit containing the changes between updated ShadowDocument and the ClientDocument.
    This method would be called when the client receives an update from the server and need
    to produce an Edit to be able to patch the ClientDocument.

    - parameter shadowDocument: the ShadowDocument patched with updates from the server
    - parameter document: the ClientDocument.
    - returns: Edit the edit representing the diff between the shadow document and the client document.
    */
    open func clientDiff(clientDocument: ClientDocument<JsonNode>, shadow: ShadowDocument<JsonNode>) -> JsonPatchEdit {
        let diffsList:[NSDictionary] = JSONPatch.createPatchesComparingCollectionsOld(clientDocument.content, toNew:shadow.clientDocument.content) as! [NSDictionary]
        return edit(clientDocument: shadow.clientDocument, shadow: shadow, diffs: diffsList)
    }

    fileprivate func edit(clientDocument: ClientDocument<JsonNode>, shadow: ShadowDocument<JsonNode>, diffs: [NSDictionary]) -> JsonPatchEdit {
        return JsonPatchEdit(clientId: clientDocument.clientId, documentId: clientDocument.id, clientVersion: shadow.clientVersion, serverVersion: shadow.serverVersion, checksum: "", diffs: asAeroGearDiffs(diffs))
    }
    
    fileprivate func asAeroGearDiffs(_ diffs: [NSDictionary]) -> [JsonPatchDiff] {
        return diffs.map {
            let val = $0 as! [String: AnyObject]
            let op: String = val["op"] as! String
            let value: AnyObject? = val["value"]
            let path: String = val["path"] as! String
            return JsonPatchDiff(operation: JsonPatchSynchronizer.asAeroGearOperation(op), path: path, value: value)
        }
    }
    
    fileprivate class func asAeroGearOperation(_ op: String) -> JsonPatchDiff.Operation {
        switch op {
        case "remove":
            return JsonPatchDiff.Operation.Remove
        case "add":
            return JsonPatchDiff.Operation.Add
        case "test":
            return JsonPatchDiff.Operation.Test
        case "move":
            return JsonPatchDiff.Operation.Move
        case "replace":
            return JsonPatchDiff.Operation.Replace
        case "copy":
            return JsonPatchDiff.Operation.Copy
        default:
            return JsonPatchDiff.Operation.Test
        }
    }
    
    /**
    Called when the document should be patched.
    
    - parameter edit: the Edit containing the diffs/patches.
    - parameter document: the ClientDocument to be patched.
    - returns: ClientDocument a new patched document.
    */
    open func patchDocument(edit: JsonPatchEdit, clientDocument: ClientDocument<JsonNode>) -> ClientDocument<JsonNode> {
        // we need a mutable copy of the json node
        // https://github.com/grgcombs/JSONTools/blob/master/JSONTools%2FJSONPatch.m#L424
        let collection = clientDocument.content as NSDictionary
        let mutableCollection: NSMutableDictionary = collection.mutableCopy() as! NSMutableDictionary
        
        // To get a patched document, we need to add a _get operation at he end of each diff as described in
        // https://github.com/grgcombs/JSONTools/blob/master/JSONTools%2FJSONPatch.h#L26
        // this operation is not part of JSON Patch spec though
        // https://tools.ietf.org/html/rfc6902
        var diffWithGetOperation = edit.diffs
        diffWithGetOperation.append(JsonPatchDiff(operation: JsonPatchDiff.Operation.Get))
        
        let results: AnyObject! = JSONPatch.applyPatches(asJsonPatchDiffs(diffs: diffWithGetOperation) as [AnyObject], toCollection: mutableCollection) as AnyObject!
        return ClientDocument<JsonNode>(id: clientDocument.id, clientId: clientDocument.clientId, content: results as! JsonNode)
    }
    
    /**
    Called when the shadow should be patched. Is called when an update is recieved.
    
    - parameter edit: the Edit containing the diffs/patches.
    - parameter shadowDocument: the ShadowDocument to be patched.
    - returns: ShadowDocument a new patched shadow document.
    */
    open func patchShadow(edit: JsonPatchEdit, shadow: ShadowDocument<JsonNode>) -> ShadowDocument<JsonNode> {
        return ShadowDocument(clientVersion: edit.clientVersion, serverVersion: shadow.serverVersion, clientDocument: patchDocument(edit: edit, clientDocument: shadow.clientDocument))
    }
    
    /**
    Produces a Edit containing the changes between the updated ClientDocument
    and the ShadowDocument.
    <br/><br/>
    Calling the method is the first step in when starting a client side synchronization. We need to
    gather the changes between the updates made by the client and the shadow document.
    The produced Edit can then be passed to the server side.

    - parameter document: the ClientDocument containing updates made by the client.
    - parameter shadowDocument: the ShadowDocument for the ClientDocument.
    - returns: Edit the edit representing the diff between the client document and it's shadow document.
    */
    open func serverDiff(serverDocument: ClientDocument<JsonNode>, shadow: ShadowDocument<JsonNode>) -> JsonPatchEdit {
        let diffsList:[NSDictionary] = JSONPatch.createPatchesComparingCollectionsOld(shadow.clientDocument.content, toNew:serverDocument.content) as! [NSDictionary]
        return edit(clientDocument: shadow.clientDocument, shadow: shadow, diffs: diffsList)
    }

    fileprivate func asJsonPatchDiffs(diffs: [JsonPatchDiff]) -> [[String: Any]] {
        return diffs.map { ["op": $0.operation.rawValue, "path": $0.path, "value": $0.value ?? ""] }
    }
    
    /**
    Creates a PatchMessage by parsing the passed-in json.
    
    - parameter json: the json representation of a PatchMessage.
    - returns: PatchMessage the created PatchMessage.
    */
    open func patchMessageFromJson(json: String) -> JsonPatchMessage? {
        return JsonPatchMessage().asPayload(json: json)
    }
    
    /**
    Creates a new PatchMessage with the with the type of Edit that this
    synchronizer can handle.

    - parameter documentId: the document identifier for the PatchMessage.
    - parameter clientId: the client identifier for the PatchMessage.
    - parameter edits: the Edits for the PatchMessage.
    - returns: PatchMessage the created PatchMessage.
    */
    open func createPatchMessage(id: String, clientId: String, edits: [JsonPatchEdit]) -> JsonPatchMessage? {
        return JsonPatchMessage(id: id, clientId: clientId, edits: edits)
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
    
    - parameter content: the content to be added.
    - parameter objectNode: as a string to add the content to.
    - parameter fieldName: the name of the field.
    */
    open func add(content: ClientDocument<JsonNode>, fieldName:String, objectNode:inout String) {
        objectNode += "\"content\":"
        // convert client document to json
        let data = try! JSONSerialization.data(withJSONObject: content.content, options:JSONSerialization.WritingOptions(rawValue: 0))
        objectNode += NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }
}

