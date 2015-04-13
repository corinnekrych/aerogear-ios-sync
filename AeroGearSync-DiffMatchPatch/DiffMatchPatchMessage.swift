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

/**
Represents a stack of changes made on the server of client side.
<br/><br/>
A DiffMatchPatchMessage is what is passed between the client and the server. It contains an array of Edits that represent updates to be performed on the opposing sides document. 
<br/><br/>
DiffMatchPatchMessage works with JsonPatch Synchronizer.
*/
public struct DiffMatchPatchMessage:PatchMessage, Printable {
    
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
    public let edits: [DiffMatchPatchEdit]!
    
    /**
    Printable protocol implementation, provides a string representation of the object.
    */
    public var description: String {
        return "DiffMatchPatchMessage[documentId=\(documentId), clientId=\(clientId), edits=\(edits)]"
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
    
    :param: id represents an id of PatchMessage.
    :param: clientId represents an id of the client session.
    :param: diff list of differences.
    */
    public init(id: String, clientId: String, edits: [DiffMatchPatchEdit]) {
        self.documentId = id
        self.clientId = clientId
        self.edits = edits
    }
    
    /**
    Transforms this payload to a JSON String representation.
    
    :returns: a string representation of JSON object.
    */
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
    
    /**
    Transforms the passed in string JSON representation into this payloads type.
    
    :param: json a string representation of this payloads type.
    :returns: DiffMatchPatchMessage an instance of this payloads type.
    */
    public func fromJson(var json: String) -> DiffMatchPatchMessage? {
        if let dict = asDictionary(json) {
            let id = dict["id"] as! String
            let clientId = dict["clientId"] as! String
            var edits = [DiffMatchPatchEdit]()
            if let e = dict["edits"] as? [[String: AnyObject]] {
                for edit in e {
                    var diffs = [DiffMatchPatchDiff]()
                    if let d = edit["diffs"] as? [[String: AnyObject]] {
                        for diff in d {
                            diffs.append(DiffMatchPatchDiff(operation:  DiffMatchPatchDiff.Operation(rawValue: diff["operation"] as! String)!,
                                text: diff["text"] as! String))
                        }
                    }
                    
                    edits.append(DiffMatchPatchEdit(clientId: clientId,
                        documentId: id,
                        clientVersion: edit["clientVersion"] as! Int,
                        serverVersion: edit["serverVersion"] as! Int,
                        checksum: edit["checksum"] as! String,
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
        return NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
    }
}