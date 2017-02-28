#
# Be sure to run `pod lib lint DQReorderableLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DQReorderableLayout'
  s.version          = '0.0.1'
  s.summary          = 'DQReorderableLayout is a UICollectionView layout which you can move items with drag and drop'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
It is used to show how to build a route system in iOS app, and I keep it simple and clear.WLRRoute provide url matching , primitive parameters transfer, target callback block , custom handler can overwrite  transitionWithRequest to navigate source to target.
                       DESC

  s.homepage         = 'https://github.com/blueseaguo/DQReorderableLayout'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Neo' => '397805741@qq.com' }
  s.source           = { :git => 'https://github.com/blueseaguo/DQReorderableLayout.git',}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'DQReorderableLayout/DQReorderableLayout/*'
  
  # s.resource_bundles = {
  #   'WLRRoute' => ['DQReorderableLayout/DQReorderableLayout/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
