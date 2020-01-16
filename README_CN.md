![AnyImageKit](https://github.com/AnyImageProject/AnyImageProject.github.io/raw/master/Resources/TitleMap@2x.png)

`AnyImageKit` 是一个选取与编辑图片的工具套件，使用 Swift 编写。

## 功能

- [x] UI 外观支持浅色/深色/自动 (iOS 13.0+)
- [x] 默认主题与微信相似
- [x] 支持多选/混合内容选择
- [x] 支持的媒体类型:
    - [x] Photo
    - [x] GIF
    - [x] Live Photo
    - [x] Video
- [x] 支持在选择时直接拍照
- [ ] 编辑图片 (技术预览版)
    - [x] 涂鸦
    - [ ] 表情
    - [x] 文字
    - [x] 裁剪
    - [x] 马赛克
- [ ] 多平台支持
    - [x] iOS
    - [x] iPadOS (暂不支持编辑)
    - [x] Mac Catalyst (技术预览版，暂不支持编辑)
    - [ ] macOS
    - [ ] tvOS

## 要求

- iOS 10.0+
- Xcode 11.0+
- Swift 5.0+

## 安装

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

将下面内容添加到 `Podfile`，并执行依赖更新。

```ruby
pod 'AnyImageKit'
```

### [Carthage](https://github.com/Carthage/Carthage)

将下面内容添加到 `Cartfile`，并执行依赖更新。

```ogdl
github "AnyImageProject/AnyImageKit"
```

> 由于 Carthage 的依赖问题，不支持 `--no-use-binaries`，请直接使用我们的二进制文件。

## 使用方法

> 我们在 [Wiki](https://github.com/AnyImageProject/AnyImageKit/wiki) 中提供了更详细的使用说明。

### 快速上手

```swift
import AnyImageKit

let controller = ImagePickerController(delegate: self)
present(controller, animated: true, completion: nil)

/// ImagePickerControllerDelegate
func imagePickerDidCancel(_ picker: ImagePickerController) {
    // 你的业务代码，处理取消(存在默认实现，如果需要额外行为请自行实现本方法)
    picker.dismiss(animated: true, completion: nil)
}
    
func imagePicker(_ picker: ImagePickerController, didFinishPicking assets: [Asset], useOriginalImage: Bool) {
    // 你的业务代码，处理选中的资源
    let images = assets.map { $0.image }
    picker.dismiss(animated: true, completion: nil)
}
```

### 获取内容数据
```swift
/// Fetch Video URL 
/// - Note: Only for `MediaType` Video
/// - Parameter options: Video URL Fetch Options
/// - Parameter completion: Video URL Fetch Completion
func fetchVideoURL(options: VideoURLFetchOptions = .init(), completion: @escaping VideoURLFetchCompletion)

// Call
asset.fetchVideoURL { (result) in
    // Your code
}
```

## 预览

![](https://github.com/AnyImageProject/AnyImageProject.github.io/raw/master/Resources/QuickLook.gif)

## 版权协议

AnyImageKit 基于 MIT 协议进行分发和使用，更多信息参见[协议文件](./LICENSE)。
