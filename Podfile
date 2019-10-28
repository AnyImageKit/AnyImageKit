# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'AnyImagePicker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SnapKit', '~> 5.0'

end

target 'Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SnapKit', '~> 5.0'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DYLIB_COMPATIBILITY_VERSION'] = ''
        end
    end
end
