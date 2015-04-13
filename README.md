# aerogear ios sync [![Build Status](https://travis-ci.org/aerogear/aerogear-ios-sync.png)](https://travis-ci.org/aerogear/aerogear-ios-sync) [![Pod Version](http://img.shields.io/cocoapods/v/AeroGearSync.svg?style=flat)](http://cocoadocs.org/docsets/AeroGearSync/)

> **NOTE:**  The library has been tested with Xcode 6.3

AeroGear iOS Differential Synchronization Client Engine represents a client side implementation for [AeroGear Differential 
Synchronization (DS) Server](https://github.com/aerogear/aerogear-sync-server/).

|                 | Project Info  |
| --------------- | ------------- |
| License:        | Apache License, Version 2.0  |
| Build:          | CocoaPods  |
| Documentation:  | http://aerogear.org/ios/  |
| Issue tracker:  | https://issues.jboss.org/browse/AGIOS  |
| Mailing lists:  | [aerogear-users](http://aerogear-users.1116366.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-users))  |
|                 | [aerogear-dev](http://aerogear-dev.1069024.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-dev))  |

## Build, test and play with aerogear-ios-sync

1. Clone this project

2. Get the dependencies

The project uses [cocoapods](http://cocoapods.org) 0.36 release for handling its dependencies. As a pre-requisite, install [cocoapods](http://blog.cocoapods.org/CocoaPods-0.36/) and then install the pod. On the root directory of the project run:
```bash
pod install
```
3. open AeroGearSync.xcworkspace

## Adding the library to your project 
To add the library in your project, you can either use [Cocoapods](http://cocoapods.org) or manual install in your project. See the respective sections below for instructions:

### Using [Cocoapods](http://cocoapods.org)
Support for Swift frameworks is supported from [CocoaPods-0.36 release](http://blog.cocoapods.org/CocoaPods-0.36/) upwards. In your ```Podfile``` add:

```
source 'https://github.com/CocoaPods/Specs.git'

xcodeproj 'YourProjectName.xcodeproj'
platform :ios, '8.0'
use_frameworks!

pod 'AeroGearSync'
```

and then:

```bash
pod install
```

to install your dependencies.

### Manual Installation
Follow these steps to add the library in your Swift project:

1. Add AeroGearSync as a [submodule](http://git-scm.com/docs/git-submodule) in your project. Open a terminal and navigate to your project directory. Then enter:
```bash
git submodule add https://github.com/aerogear/aerogear-ios-sync.git
```
2. Open the `aerogear-ios-sync` folder, and drag the `AeroGearSync.xcodeproj` into the file navigator in Xcode.
3. In Xcode select your application target  and under the "Targets" heading section, ensure that the 'iOS  Deployment Target'  matches the application target of AeroGearSync.framework (Currently set to 8.0).
5. Select the  "Build Phases"  heading section,  expand the "Target Dependencies" group and add  `AeroGearSync.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `AeroGearSync.framework`.

## Documentation

For more details about the current release, please consult [our documentation](https://aerogear.org/sync/).

## Development

If you would like to help develop AeroGear you can join our [developer's mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev), join #aerogear on Freenode, or shout at us on Twitter @aerogears.

Also takes some time and skim the [contributor guide](http://aerogear.org/docs/guides/Contributing/)

## Questions?

Join our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users) for any questions or help! We really hope you enjoy app development with AeroGear!

## Found a bug?

If you found a bug please create a ticket for us on [Jira](https://issues.jboss.org/browse/AGIOS) with some steps to reproduce it.