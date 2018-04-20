#
# Be sure to run `pod lib lint MovingArcsMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MovingArcsMenu'
  s.version          = '0.1.0'
  s.summary          = 'MovingArcsMenu is a sublcass of UIView that let you have a buttons inside arcs at the bottom right of a view'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MovingArcsMenu is a UIView subclass that let you have buttons inside arcs on the bottom right of a view. The buttons inside the view can have just a backgound image. The arcs ar shown and hidden using a cool animation.
It is possible to customize the number of buttons, the color of the arcs and their shadow.
MovingArcsMenu is very useful to create a bottom right menu, this position is the most accesible on every smartphone.
                       DESC

  s.homepage         = 'https://github.com/aruffolo/MovingArcsView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'aruffolo' => 'antonioruffolo2@gmail.com' }
  s.source           = { :git => 'https://github.com/aruffolo/MovingArcsView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MovingArcsMenu/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MovingArcsMenu' => ['MovingArcsMenu/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
