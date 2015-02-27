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
import AeroGearSync

public struct DiffMatchPatchMessage:PatchMessage, Printable {
    public let documentId: String!
    public let clientId: String!
    public let edits: [DiffMatchPatchEdit]!
    
    public var description: String {
        return "DiffMatchPatchMessage[documentId=\(documentId), clientId=\(clientId), edits=\(edits)]"
    }
    
    public init() {}
    
    public init(id: String, clientId: String, edits: [DiffMatchPatchEdit]) {
        self.documentId = id
        self.clientId = clientId
        self.edits = edits
    }
    
    public func asJson() -> String {
        var dict = [String: AnyObject]()
        
        dict["msgType"] = "patch"
        dict["id"] = documentId
        dict["clientId"] = clientId
        dict["edits"] = self.edits.map { (edit:DiffMatchPatchEdit) -> [String: AnyObject] in
            var dict = [String: AnyObject]()
            
            dict["clientVersion"] = edit.clientVersion
            dict["serverVersion"] = edit.serverVersion
            dict["checksum"] = edit.checksum
            
            dict["diffs"] = edit.diffs.map { (diff:DiffMatchPatchDiff) -> [String: AnyObject] in
                var dict = [String: AnyObject]()
                
                dict["operation"] = diff.operation.rawValue
                dict["text"] = (diff.text as String).stringByReplacingOccurrencesOfString("\"", withString: "\\\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
                return dict
            }
            return dict
        }
        
        return asJsonString(dict)!
    }

    public func fromJson(var json: String) -> DiffMatchPatchMessage? {
        if let dict = asDictionary(json) {
            let id = dict["id"] as String
            let clientId = dict["clientId"] as String
            var edits = [DiffMatchPatchEdit]()
            if let e = dict["edits"] as? [[String: AnyObject]] {
                for edit in e {
                    var diffs = [DiffMatchPatchDiff]()
                    if let d = edit["diffs"] as? [[String: AnyObject]] {
                        for diff in d {
                            diffs.append(DiffMatchPatchDiff(operation:  DiffMatchPatchDiff.Operation(rawValue: diff["operation"] as String)!,
                                text: diff["text"] as String))
                        }
                    }
                    
                    edits.append(DiffMatchPatchEdit(clientId: clientId,
                        documentId: id,
                        clientVersion: edit["clientVersion"] as Int,
                        serverVersion: edit["serverVersion"] as Int,
                        checksum: edit["checksum"] as String,
                        diffs: diffs))
                }
            }
            
            return DiffMatchPatchMessage(id: id, clientId: clientId, edits: edits)
        }
        return Optional.None
    }
    
    /**
    Tries to convert the passed in String into a Swift Dictionary<String, AnyObject>
    
    :param: jsonString the JSON string to convert into a Dictionary
    :returns: Optional Dictionary<String, AnyObject>
    */
    public func asDictionary(jsonString: String) -> [String: AnyObject]? {
        var jsonErrorOptional: NSError?
        return NSJSONSerialization.JSONObjectWithData((jsonString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
            options: NSJSONReadingOptions(0), error: &jsonErrorOptional) as? [String: AnyObject]
    }
    
    /**
    Tries to convert the passed in Dictionary<String, AnyObject> into a JSON String representation.
    
    :param: the Dictionary<String, AnyObject> to try to convert.
    :returns: optionally the JSON string representation for the dictionary.
    */
    public func asJsonString(dict: [String: AnyObject]) -> String? {
        var jsonErrorOptional: NSError?
        var data = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &jsonErrorOptional)
        return NSString(data: data!, encoding: NSUTF8StringEncoding)
    }
}