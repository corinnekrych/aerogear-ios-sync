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
A backup of the ShadowDocument.
<br/><br/>
```<T>``` the type of the Document that this instance backups.
*/
public class BackupShadowDocument<T>: CustomStringConvertible {
    
    /**
    Represents the version of this backup shadow.
    */
    public let version: Int
    
    /**
    The ShadowDocument that this instance is backing up.
    */
    public let shadowDocument: ShadowDocument<T>
    
    /**
    Default init.
    
    :param: version of this backup shadow.
    :param: shadowDocument that this instance is backing up.
    */
    public init(version: Int, shadowDocument: ShadowDocument<T>) {
        self.version = version
        self.shadowDocument = shadowDocument
    }

    /**
    Printable protocol implementation, provides a string representation of the object.
    */
    public var description: String {
        return "BackupShadowDocument[version=\(version), shadowDocument=\(shadowDocument)]"
    }
}
