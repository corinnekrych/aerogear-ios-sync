# AeroGear iOS Differential Synchronization Client Engine [![Build Status](https://travis-ci.org/aerogear/aerogear-ios-sync.png)](https://travis-ci.org/aerogear/aerogear-ios-sync) [![Pod Version](http://img.shields.io/cocoapods/v/AeroGearSync.svg?style=flat)](http://cocoadocs.org/docsets/AeroGearSync/)

> This module is beta software, it currently supports Xcode 6.1.1

This project represents a client side implementation for [AeroGear Differential 
Synchronization (DS) Server](https://github.com/aerogear/aerogear-sync-server/).

## Prerequisites 

This project used [CocoaPods](http://cocoapods.org/) to managed its dependencies. The following command 
must be run prior to building:
    
    sudo gem install cocoapods --pre
    pod install

## Building

Building can be done by opening the project in Xcode:

    open AeroGearSync.xcworkspace

or you can use the command line.
Make sure you are using Xcode6.0: 

    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

    xcodebuild -workspace AeroGearSync.xcworkspace -scheme AeroGearSync build

## Testing
Tests can be run from with in Xcode using Product->Test menu option (CMD+U).  
You can also run test from the command:

    xcodebuild -workspace AeroGearSync.xcworkspace -scheme AeroGearSync -destination 'platform=iOS Simulator,name=iPhone 5s' test

### [CocoaPods](http://cocoapods.org/) 
At this time, Cocoapods support for Swift frameworks is supported in a [pre-release](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/).

To use AeroGearSync in your project add the following 'Podfile' to your project

    source 'https://github.com/CocoaPods/Specs.git'

    xcodeproj 'YourProjectName.xcodeproj'
    platform :ios, '8.0'

    pod 'AeroGearSync', :git => "https://github.com/aerogear/aerogear-ios-sync.git", :branch => "master"

    target 'YourProjectNameTests' do
        pod 'AeroGearSync', :git => "https://github.com/aerogear/aerogear-ios-sync.git", :branch => "master"
    end
    
Then run:

    pod install

#### Updating the Cocoapod
You can validate AeroGearSync.podspec using:

    pod spec lint AeroGearSync.podspec  --verbose --allow-warnings

This should be tested with a sample project before releasing it. This can be done by adding the following line to a ```Podfile```:
    
    pod 'AeroGearSync', :git => "https://github.com/username/aerogear-ios-sync.git", :branch => "cocoapods-update"

Then run:
    
    pod install

If all goes well you are ready to release. First, create a tag and push:

    git tag -s 'version'
    git push --tags

Once the tag is available you can send the library to the Specs repo. 
For this you'll have to follow the instructions in [Getting Setup with Trunk](http://guides.cocoapods.org/making/getting-setup-with-trunk.html).

    pod trunk push AeroGearSync.podspec

