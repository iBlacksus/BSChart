Pod::Spec.new do |spec|
  spec.name         = 'BSChart'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage     = 'https://github.com/iBlacksus/BSChart'
  spec.authors      = { 'iBlacksus' => 'iblacksus@gmail.com' }
  spec.summary      = 'BSChart is a simple and useful chart library written on Swift'
  spec.source       = { :git => 'https://github.com/iBlacksus/BSChart.git', :tag => spec.version }
  spec.screenshots 	= "https://raw.githubusercontent.com/iBlacksus/BSChart/master/ReadmeResources/demo1.jpg"
  spec.source_files = 'BSChart', 'BSChart/**/*'
  spec.requires_arc = true
  spec.ios.deployment_target  = '10.0'
  spec.ios.framework  = 'UIKit'
  spec.swift_versions = '5.0'
end