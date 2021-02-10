Pod::Spec.new do |s|
  s.name = 'CombineTestHelpers'
  s.version = '0.1.0'
  s.summary = 'Test assertions for Combine types'
  s.homepage = 'https://github.com/mokagio/CombineTestHelpers'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Gio Lodi' => 'gio@mokacoding.com' }
  s.social_media_url = 'http://twitter.com/mokagio'
  s.source = { :git => 'https://github.com/mokagio/CombineTestHelpers.git', :tag => "v#{s.version}" }
  s.source_files = 'Sources/**/*.{h,swift}'
  s.framework = "XCTest"
  s.requires_arc = true
  s.swift_versions = [5.0]
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  # TODO: Add support for watchOS and tvOS
  # s.watchos.deployment_target = '2.0'
  # s.tvos.deployment_target = '9.0'
end
