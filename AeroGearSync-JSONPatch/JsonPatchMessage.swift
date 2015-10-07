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
Represents a stack of changes made on the server of client side.
<br/><br/>
A JsonPatchMessage is what is passed between the client and the server. It contains an array of
Edits that represent updates to be performed on the opposing sides document. 
<br/><br/>
JsonPatchMessage works with JsonPatch Synchronizer.
*/
public struct JsonPatchMessage: PatchMessage, CustomStringConvertible {
    
    /**
    Identifies the document that this edit is related to.
    */
    public let documentId: String!
    
    /**
    Identifies the client that this edit instance belongs to.
    */
    public let clientId: String!
    
    /**
    The list Edits.
    */
    public let edits: [JsonPatchEdit]!
    
    public var description: String {
        return "JsonPatchMessage[documentId=\(documentId), clientId=\(clientId), edits=\(edits)]"
    }
    
    /**
    Default init.
    */
    public init() {
        self.documentId = nil
        self.clientId = nil
        self.edits = nil
    }
    
    /**
    Default init.
    
    - parameter pathMessageId: unique id.
    - parameter client: id to identify the client sesion.
    - parameter list: of edits that makes the content of the patch.
    */
    public init(id: String, clientId: String, edits: [JsonPatchEdit]) {
        self.documentId = id
        self.clientId = clientId
        self.edits = edits
    }
    
    /**
    Transforms this payload to a JSON String representation.
    - returns: s string representation of JSON object.
    */
    public func asJson() -> String {
        var dict = [String: AnyObject]()
        
        dict["msgType"] = "patch"
        dict["id"] = documentId
        dict["clientId"] = clientId
        dict["edits"] = self.edits.map { (edit:JsonPatchEdit) -> [String: AnyObject] in
            var dict = [String: AnyObject]()
            
            dict["clientVersion"] = edit.clientVersion
            dict["serverVersion"] = edit.serverVersion
            dict["checksum"] = edit.checksum
            
            dict["diffs"] = edit.diffs.map { (diff:JsonPatchDiff) -> [String: AnyObject] in
                var dict = [String: AnyObject]()
                
                dict["op"] = diff.operation.rawValue
                dict["path"] = diff.path
                if let val = diff.value as? String {
                    dict["value"] = val.stringByReplacingOccurrencesOfString("\"", withString: "\\\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
                }
                return dict
            }
            return dict
        }
        
        return asJsonString(dict)!
    }
    
    /**
    Transforms the passed in string JSON representation into this payloads type.
    
    - parameter json: a string representation of this payloads type.
    - returns: JsonPatchMessage an instance of this payloads type.
    */
    public func fromJson(json:String) -> JsonPatchMessage? {
        if let dict = asDictionary(json) {
            let id = dict["id"] as! String
            let clientId = dict["clientId"] as! String
            var edits = [JsonPatchEdit]()
            
            if let e = dict["edits"] as? [[String: AnyObject]] {
                for edit in e {
                    var diffs = [JsonPatchDiff]()
                    if let d = edit["diffs"] as? [[String: AnyObject]] {
                        for diff in d {
                            diffs.append(JsonPatchDiff(operation: JsonPatchDiff.Operation(rawValue: diff["op"] as! String)!,
                                path: diff["path"] as! String, value: diff["value"] as? String))
                        }
                    }
                    
                    edits.append(JsonPatchEdit(clientId: clientId,
                        documentId: id,
                        clientVersion: edit["clientVersion"] as! Int,
                        serverVersion: edit["serverVersion"] as! Int,
                        checksum: edit["checksum"] as! String,
                        diffs: diffs))
                }
            }
            return JsonPatchMessage(id: id, clientId: clientId, edits: edits)
        }
        return Optional.None
    }
    
    /**
    Tries to convert the passed in String into a Swift Dictionary<String, AnyObject>
    
    - parameter jsonString: the JSON string to convert into a Dictionary
    - returns: Optional Dictionary<String, AnyObject>
    */
    public func asDictionary(jsonString: String) -> [String: AnyObject]? {
        return try! NSJSONSerialization.JSONObjectWithData((jsonString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
            options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]
    }
    
    /**
    Tries to convert the passed in Dictionary<String, AnyObject> into a JSON String representation.
    
    - parameter the: Dictionary<String, AnyObject> to try to convert.
    - returns: optionally the JSON string representation for the dictionary.
    */
    public func asJsonString(dict: [String:  AnyObject]) -> String? {
        var data: NSData?
        do {
            data = try NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(rawValue: 0))
        } catch {
            data = nil
        }
        return NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
    }
}