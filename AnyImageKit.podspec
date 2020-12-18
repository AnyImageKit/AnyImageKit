Pod::Spec.new do |s|
    s.name = 'AnyImageKit'
    s.version = '0.11.0'
    s.license = 'MIT'
    s.summary = 'AnyImageKit is a toolbox for picking and editing photos.'
    s.homepage = 'https://github.com/AnyImageProject/AnyImageKit'
    s.authors = {
        'anotheren' => 'liudong.edward@gmail.com',
        'RayJiang16' => '1184731421@qq.com',
    }
    s.source = { :git => 'https://github.com/AnyImageProject/AnyImageKit.git', :tag => s.version }
    s.ios.deployment_target = '10.0'
    s.swift_versions = ['5.0', '5.1']
    s.frameworks = 'Foundation'
    
    s.default_subspecs = 'Core', 'Picker', 'Editor', 'Capture'
    
    s.subspec 'Core' do |core|
        core.source_files = 'Sources/AnyImageKit/Core/**/*.swift'
        core.resources = 'Sources/AnyImageKit/Resources/Core/**/*'
        core.dependency 'SnapKit'
    end
    
    s.subspec 'Picker' do |picker|
        picker.source_files = 'Sources/AnyImageKit/Picker/**/*.swift'
        picker.resources = 'Sources/AnyImageKit/Resources/Picker/**/*'
        picker.dependency 'AnyImageKit/Core'
        picker.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'ANYIMAGEKIT_ENABLE_PICKER' }
    end
    
    s.subspec 'Editor' do |editor|
        editor.source_files = 'Sources/AnyImageKit/Editor/**/*.swift'
        editor.resources = 'Sources/AnyImageKit/Resources/Editor/**/*'
        editor.dependency 'AnyImageKit/Core'
        editor.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'ANYIMAGEKIT_ENABLE_EDITOR' }
    end
    
    s.subspec 'Capture' do |capture|
        capture.source_files = 'Sources/AnyImageKit/Capture/**/*.{swift,metal}'
        capture.resources = 'Sources/AnyImageKit/Resources/Capture/**/*'
        capture.dependency 'AnyImageKit/Core'
        capture.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'ANYIMAGEKIT_ENABLE_CAPTURE' }
    end
    
end
