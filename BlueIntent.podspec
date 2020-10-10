#
# Be sure to run `pod lib lint BlueIntent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BlueIntent'
  s.version          = '0.1.0'
  s.summary          = 'Swfit block utilities.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#  s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC

  s.homepage         = 'https://github.com/qiuzhifei/BlueIntent'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qiuzhifei' => 'qiuzhifei521@gmail.com' }
  s.source           = { :git => 'https://github.com/qiuzhifei/BlueIntent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  #  s.source_files = 'BlueIntent/Classes/Base/**/*'
  
  # s.resource_bundles = {
  #   'BlueIntent' => ['BlueIntent/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.default_subspecs = 'Foundation', 'UIKit'
  
  s.subspec 'Base' do |ss|
    ss.source_files = 'BlueIntent/Classes/Base/**/*'
  end
   
  s.subspec 'Foundation' do |ss|
    ss.source_files = 'BlueIntent/Classes/Foundation/**/*'
    ss.dependency 'BlueIntent/Base'
  end
  
  s.subspec 'UIKit' do |ss|
    ss.source_files = 'BlueIntent/Classes/UIKit/**/*'
    ss.dependency 'BlueIntent/Base'
    ss.dependency 'BlueIntent/Foundation'
  end
  
  s.subspec 'AppleLogin' do |ss|
    ss.source_files = 'BlueIntent/Classes/AppleLogin/**/*'
    ss.dependency 'BlueIntent/Base'
  end
  
  s.subspec 'Layout' do |ss|
    ss.source_files = 'BlueIntent/Classes/Layout/**/*'
    ss.dependency 'BlueIntent/Base'
    ss.dependency 'PureLayout',       '~> 3.1.6'
  end
  
end
