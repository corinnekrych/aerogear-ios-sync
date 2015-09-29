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
A marker interface that represents a diff or two versions of a document/object.
<br/><br/>
The actual implementation of a diff will vary depending on the type of content the
ClientSynchronizer can handle.
*/
public protocol Difference: CustomStringConvertible {
 // leave this coment for jazzy to generate doc ok
}