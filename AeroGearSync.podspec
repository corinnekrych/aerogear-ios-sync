Pod::Spec.new do |s|
  s.name         = "AeroGearSync"
  s.version      = "1.0.0-alpha.3"
  s.summary      = "An iOS Sync Engine for AeroGear Differential Synchronization"
  s.homepage     = "https://github.com/aerogear/aerogear-sync-server"
  s.license      = 'Apache License, Version 2.0'
  s.author       = "Red Hat, Inc."
  s.source       = {:git => 'https://github.com/aerogear/aerogear-ios-sync.git',  :tag => s.version }
  s.platform     = :ios, 8.0
  s.requires_arc = 'true'  
  s.default_subspec = 'JSONPatch'
  
  s.subspec 'Core' do |core|
       core.source_files = 'AeroGearSync/*.{h,swift}'
  end

  s.subspec 'DiffMatchPatch' do |diffmatchpatch|
     diffmatchpatch.source_files = 'AeroGearSync-DiffMatchPatch/*.{h,swift}'
     diffmatchpatch.dependency  'AeroGearSync/Core'
     diffmatchpatch.dependency  'DiffMatchPatch', '0.1.2'
  end

  s.subspec 'JSONPatch' do |jsonpatch|
     jsonpatch.source_files = 'AeroGearSync-JSONPatch/*.{h,swift}'
     jsonpatch.dependency  'AeroGearSync/Core'     
     jsonpatch.dependency  'JSONTools', '1.0.5'
  end
  
end
