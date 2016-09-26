source 'https://github.com/CocoaPods/Specs.git'

project 'AeroGearSyncJsonPatch.xcodeproj'
platform :ios, '8.0'
use_frameworks!

target 'AeroGearSyncJsonPatch' do
	pod 'JSONTools', '1.0.5'
	target 'AeroGearSyncJsonPatchTests' do
		pod 'JSONTools', '1.0.5'
	end
end

# Workaround to fix swift version to 2.3 for Pods. 
# it could be removed once CocoaPods 1.1.0 is released.
# https://github.com/CocoaPods/CocoaPods/issues/5521
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end