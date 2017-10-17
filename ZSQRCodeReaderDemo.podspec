#
# Be sure to run `pod lib lint ZSQRCodeReaderDemo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZSQRCodeReaderDemo'
  s.version          = '0.1.0'
  s.summary          = '二维码/条形码扫描读取，界面及交互模仿微信。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
二维码/条形码扫描读取，界面及交互模仿微信。相册照片选择依赖第三方库TZImagePickerController
                       DESC

  s.homepage         = 'https://github.com/safiriGitHub/QRCodeReader'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'safiriGitHub' => 'safiri@163.com' }
  s.source           = { :git => 'https://github.com/safiriGitHub/QRCodeReader.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZSQRCodeReaderDemo/ZSQRCodeReader/**/*'
  
  # s.resource_bundles = {
  #   'ZSQRCodeReaderDemo' => ['ZSQRCodeReaderDemo/Assets/*.png']
  # }

  s.public_header_files = 'ZSQRCodeReaderDemo/ZSQRCodeReader/**/*.h'
  s.frameworks = 'UIKit', 'AVFoundation'
  s.dependency 'TZImagePickerController'
end
