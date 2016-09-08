# aerogear ios sync [![Build Status](https://travis-ci.org/aerogear/aerogear-ios-sync.png)](https://travis-ci.org/aerogear/aerogear-ios-sync) [![Pod Version](http://img.shields.io/cocoapods/v/AeroGearSync.svg?style=flat)](http://cocoadocs.org/docsets/AeroGearSync/)

> This module currently build with Xcode 7 (Swift 2.0) and supports iOS8, iOS9.

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

The project uses [cocoapods](http://cocoapods.org) for handling its dependencies. As a pre-requisite, install [cocoapods](http://cocoapods.org) and then install the pod. On the root directory of the project run:
```bash
pod install
```
3. open AeroGearSync.xcworkspace

## Adding the library to your project 
To add the library in your project, you can either use [CocoaPods](http://cocoapods.org) or manual install in your project. See the respective sections below for instructions:

Support for Swift frameworks is supported from [CocoaPods](http://cocoapods.org) upwards. In your ```Podfile``` add:

```
source 'https://github.com/CocoaPods/Specs.git'

project 'YourProjectName.xcodeproj'
platform :ios, '8.0'
use_frameworks!
target 'YourProjectName' do
    pod 'AeroGearSync'
end

```

and then:

```bash
pod install
```

to install your dependencies.

## Documentation

For more details about the current release, please consult [our documentation](https://aerogear.org/sync/).

## Development

If you would like to help develop AeroGear you can join our [developer's mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev), join #aerogear on Freenode, or shout at us on Twitter @aerogears.

Also takes some time and skim the [contributor guide](http://aerogear.org/docs/guides/Contributing/)

## Questions?

Join our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users) for any questions or help! We really hope you enjoy app development with AeroGear!

## Found a bug?

If you found a bug please create a ticket for us on [Jira](https://issues.jboss.org/browse/AGIOS) with some steps to reproduce it.
