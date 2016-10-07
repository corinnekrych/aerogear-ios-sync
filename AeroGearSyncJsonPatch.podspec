Pod::Spec.new do |s|
  s.name         = "AeroGearSyncJsonPatch"
  s.version      = "1.0.0-alpha.4"
  s.summary      = "An iOS Sync Engine for AeroGear Differential Synchronization"
  s.description  = <<-DESC
  AeroGearSync is the synchronisation engine based on Google Diff Match Patch algorithm. 
  To use the sync engine, you work with its sync client. 
  AeroGearSyncJsonPatch implements the protocol using Json Patch protocol rfc6902 and the Json merge rfc7386.
  AeroGearSyncDiffMatchPatch implement the Google Diff Match Patch algorithm not based on Json format. You can work using plain string and no structured model (plain text will fit).
                   DESC

  s.homepage     = "https://github.com/aerogear/aerogear-ios-sync"
  s.license      = "Apache License, Version 2.0"
  s.author       = "Red Hat, Inc."
  s.source       = { :git => 'https://github.com/aerogear/aerogear-ios-sync.git', :tag => s.version }
  s.platform     = :ios, 8.0
  s.source_files = 'AeroGearSyncJsonPatch/*.{swift}'
  s.requires_arc = true
  s.dependency  'JSONTools', '1.0.5'
end
