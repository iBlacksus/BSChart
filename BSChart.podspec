Pod::Spec.new do |s|
  s.name         = 'BSChart'
  s.version      = '1.0.4'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     = 'https://github.com/iBlacksus/BSChart'
  s.authors      = { 'iBlacksus' => 'iblacksus@gmail.com' }
  s.summary      = 'BSChart is a simple and useful chart library written on Swift'
  s.source       = { :git => 'https://github.com/iBlacksus/BSChart.git', :tag => s.version }
  s.screenshots 	= "https://raw.githubusercontent.com/iBlacksus/BSChart/master/ReadmeResources/demo1.jpg"
  s.source_files = 'BSChart/**/*.{swift}'
  s.resources = 'BSChart/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}'
  s.requires_arc = true
  s.platform = :ios
  s.ios.deployment_target  = '10.0'
  s.framework  = 'UIKit'
  s.swift_versions = '5.0'
end