#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flupick_mediaresource.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flupick_mediaresource'
  s.version          = '0.0.1'
  s.summary          = 'flutter pick images and videos'
  s.description      = <<-DESC
flutter pick images and videos
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  #图片资源处理
  s.resources = ['Classes/**/*.png', 'Classes/**/*.xib']

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
