## Swift Package Manager

[Swift Package Manager](https://github.com/apple/swift-package-manager) 是管理 Swift 代码分发的工具，与Swift构建系统集成在一起，可以自动执行依赖项的下载，编译和链接过程。

⚠️ 需要 Xcode 12.0 及以上版本来支持资源文件/本地化文件的添加。

```swift
dependencies: [
    .package(url: "https://github.com/AnyImageKit/AnyImageKit.git", .upToNextMajor(from: "0.9.0"))
]
```



## CocoaPods

[CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) 是项目依赖管理器，你可以用以下命令安装：

```ruby
$ gem install cocoapods
```

将下面内容添加到 `Podfile`

```ruby
pod 'AnyImageKit'
```

接下来执行安装命令：

```ruby
$ pod install
```



### 单独引入

一般情况下我们会引入所有默认模块，如果你只需要单独一个子模块可以使用下面的命令：

```ruby
pod 'AnyImageKit' # 引入所有默认模块
pod 'AnyImageKit', :subspecs => ['Picker'] # 只引入图片选择器
pod 'AnyImageKit', :subspecs => ['Picker', 'Editor'] # 引入图片选择器和编辑器
```

### 子模块列表

```ruby
'Picker'  # 图片选择器，默认模块
'Editor'  # 编辑器，默认模块
'Capture' # 相机，默认模块
```



## 下一步

- [Picker使用说明](https://github.com/AnyImageKit/AnyImageKit/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [Editor使用说明](https://github.com/AnyImageKit/AnyImageKit/wiki/Editor%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [Capture使用说明](https://github.com/AnyImageKit/AnyImageKit/wiki/Capture%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)
