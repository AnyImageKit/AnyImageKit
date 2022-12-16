Pod::Spec.new do |s|
    s.name = 'AnyImageKit'
    s.version = '0.15.1'
    s.license = 'MIT'
    s.summary = 'AnyImageKit is a toolbox for picking and editing photos.'
    s.homepage = 'https://github.com/AnyImageKit/AnyImageKit'
    s.authors = {
        'anotheren' => 'liudong.edward@gmail.com',
        'RayJiang16' => '1184731421@qq.com',
    }
    s.source = { :git => 'https://github.com/AnyImageKit/AnyImageKit.git', :tag => s.version }
    s.ios.deployment_target = '12.0'
    s.swift_versions = ['5.3']
    s.frameworks = 'Foundation'
    
    s.default_subspecs = 'Core', 'Picker', 'Editor', 'Capture'
    
    s.subspec 'Core' do |core|
        core.source_files = 'Sources/AnyImageKit/Core/**/*.swift'
        core.resource_bundles = {
            'AnyImageKit_Core' => ['Sources/AnyImageKit/Resources/Core/**/*']
        }
        core.dependency 'SnapKit'
        core.dependency 'Kingfisher'
    end
    
    s.subspec 'Picker' do |picker|
        picker.source_files = 'Sources/AnyImageKit/Picker/**/*.swift'
        picker.resource_bundles = {
            'AnyImageKit_Picker' => ['Sources/AnyImageKit/Resources/Picker/**/*']
        }
        picker.dependency 'AnyImageKit/Core'
        picker.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'ANYIMAGEKIT_ENABLE_PICKER' }
    end
    
    s.subspec 'Editor' do |editor|
        editor.source_files = 'Sources/AnyImageKit/Editor/**/*.swift'
        editor.resource_bundles = {
            'AnyImageKit_Editor' => ['Sources/AnyImageKit/Resources/Editor/**/*']
        }
        editor.dependency 'AnyImageKit/Core'
        editor.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'ANYIMAGEKIT_ENABLE_EDITOR' }
    end
    
    s.subspec 'Capture' do |capture|
        capture.source_files = 'Sources/AnyImageKit/Capture/**/*.{swift}'
        capture.resource_bundles = {
            'AnyImageKit_Capture' => ['Sources/AnyImageKit/Resources/Capture/**/*']
        }
        capture.dependency 'AnyImageKit/Core'
        capture.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'ANYIMAGEKIT_ENABLE_CAPTURE' }
    end
    
end
