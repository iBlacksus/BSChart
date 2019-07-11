Pod::Spec.new do |spec|
  spec.name         = 'BSChart'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage     = 'https://github.com/iBlacksus/BSChart'
  spec.authors      = { 'iBlacksus' => 'iblacksus@gmail.com' }
  spec.summary      = 'BSChart is a simple and useful chart library written on Swift'
  spec.source       = { :git => 'https://github.com/iBlacksus/BSChart.git', :tag => '1.0.0' }
  spec.source_files = 'BSChart/**/*'
  spec.framework    = 'SystemConfiguration'
  spec.ios.deployment_target  = '10.0'
  spec.ios.framework  = 'UIKit'
end