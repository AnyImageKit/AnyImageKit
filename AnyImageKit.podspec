Pod::Spec.new do |s|
    s.name = 'AnyImageKit'
    s.version = '0.4.0'
    s.license = 'MIT'
    s.summary = 'AnyImageKit is an image picker which support for multiple photos, GIFs or videos.'
    s.homepage = 'https://github.com/AnyImageProject/AnyImageKit'
    s.authors = {
        'anotheren' => 'liudong.edward@gmail.com',
        'RayJiang16' => '1184731421@qq.com',
    }
    s.source = { :git => 'https://github.com/AnyImageProject/AnyImageKit.git', :tag => s.version }
    s.ios.deployment_target = '10.0'
    s.swift_versions = ['5.0', '5.1']
    s.source_files = 'Sources/**/*.swift'
    s.resources = 'Sources/Resources/**/*'
    s.frameworks = 'Foundation'
    s.dependency 'SnapKit'
  end
