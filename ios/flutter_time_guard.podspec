#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_time_guard.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_time_guard'
  s.version          = '1.2.6'
  s.summary          = 'Detects device time and timezone tampering in Flutter apps.'
  s.description      = <<-DESC
Detects manual date, time, and timezone changes and helps validate the device
clock for security-sensitive Flutter apps.
                       DESC
  s.homepage         = 'https://github.com/M-Yahia2011/flutter_time_guard'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_time_guard/Sources/flutter_time_guard/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'flutter_time_guard_privacy' => ['flutter_time_guard/Sources/flutter_time_guard/PrivacyInfo.xcprivacy']}
end
