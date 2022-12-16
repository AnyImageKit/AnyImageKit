![AnyImageKit](https://github.com/AnyImageProject/AnyImageProject.github.io/raw/master/Resources/TitleMap@2x.png)

`AnyImageKit` 是一个选取、编辑、拍摄图片/视频的工具套件，使用 Swift 编写。

## 功能

- [x] 模块化设计
    - [x] Picker
    - [ ] Browser
    - [x] Editor
    - [x] Capture
- [x] UI 外观支持浅色/深色/自动 (iOS 13.0+)
- [x] 默认主题与微信相似
- [x] 支持多选/混合内容选择
- [x] 支持的媒体类型:
    - [x] Photo
    - [x] GIF
    - [x] Live Photo
    - [x] Video
- [x] 相机支持
    - [x] Photo
    - [x] Video
    - [ ] Live Photo
    - [ ] GIF
    - [ ] 滤镜支持
- [ ] 编辑图片 (技术预览版)
    - [x] 涂鸦
    - [ ] 表情
    - [x] 文字
    - [x] 裁剪
    - [x] 马赛克
    - [x] 旋转
    - [ ] 滤镜支持
- [x] 多平台支持
    - [x] iOS
    - [x] iPadOS
    - [x] Mac Catalyst (技术预览版，暂不支持编辑。)
    - [ ] macOS
    - [ ] tvOS
- [x] 国际化支持
    - [x] 英文 (en)
    - [x] 简体中文 (zh-Hans)
    - [x] 土耳其语 (tr)
    - [x] 葡萄牙语-巴西 (pt-BR)
    - [ ] 更多支持... (欢迎PR)

## 要求

- iOS 12.0+
- Xcode 14.1+
- Swift 5.7+

## 安装

### [Swift Package Manager](https://swift.org/package-manager/)

⚠️ 需要 Xcode 12.0 及以上版本来支持资源文件/本地化文件的添加。

```swift
dependencies: [
    .package(url: "https://github.com/AnyImageKit/AnyImageKit.git", .upToNextMajor(from: "0.15.1"))
]
```

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

将下面内容添加到 `Podfile`，并执行依赖更新。

```ruby
pod 'AnyImageKit'
```

## 使用方法

> 我们在 [Wiki](https://github.com/AnyImageKit/AnyImageKit/wiki) 中提供了更详细的使用说明。

### 准备工作

按需在你的 Info.plist 中添加以下键值:

| Key | 模块 | 备注 |
| ----- | ----  | ---- |
| NSPhotoLibraryUsageDescription | Picker | 允许访问相册 |
| NSPhotoLibraryAddUsageDescription | Picker | 允许保存图片至相册 |
| PHPhotoLibraryPreventAutomaticLimitedAccessAlert | Picker | 设置为 `YES` iOS 14+ 以禁用自动弹出添加更多照片的弹框(Picker 已适配 Limited 功能，可由用户主动触发，提升用户体验)|
| NSCameraUsageDescription | Capture | 允许使用相机 |
| NSMicrophoneUsageDescription | Capture | 允许使用麦克风 |

### 快速上手

```swift
import AnyImageKit

class ViewController: UIViewController {

    @IBAction private func openPicker(_ sender: UIButton) {
        var options = PickerOptionsInfo()
        /*
          你的业务代码，更新设置
        */
        let controller = ImagePickerController(options: options, delegate: self)
        present(controller, animated: true, completion: nil)
    }
}

extension ViewController: ImagePickerControllerDelegate {

    func imagePickerDidCancel(_ picker: ImagePickerController) {
        /*
          你的业务代码，处理用户取消(存在默认实现，如果需要额外行为请自行实现本方法)
        */
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
        let images = result.assets.map { $0.image }
        /*
          你的业务代码，处理选中的资源
        */
        picker.dismiss(animated: true, completion: nil)
    }
}
```

## 更新日志

| 版本 | 发布时间 | Xcode | Swift | iOS |
| ---- | ----  | ---- | ---- | ---- |
| [v0.15.1](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0151) | 2022-12-15 | 14.1 | 5.7 | 12.0+ |
| [v0.15.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0150) | 2022-11-11 | 14.1 | 5.7 | 12.0+ |
| [v0.14.6](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0146) | 2022-07-06 | 13.4.1 | 5.6 | 13.0+ |
| [v0.14.5](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0145) | 2022-07-05 | 13.4.1 | 5.6 | 13.0+ |
| [v0.14.4](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0144) | 2022-04-06 | 13.3 | 5.5 | 12.0+ |
| [v0.14.3](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0143) | 2021-12-28 | 13.2 | 5.5 | 12.0+ |
| [v0.14.2](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0142) | 2021-12-16 | 13.2 | 5.5 | 12.0+ |
| [v0.14.1](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0141) | 2021-11-23 | 13.1 | 5.5 | 12.0+ |
| [v0.14.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0140) | 2021-11-22 | 13.1 | 5.5 | 12.0+ |
| [v0.13.5](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0135) | 2021-10-15 | 13.0 | 5.5 | 12.0+ |
| [v0.13.4](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0134) | 2021-09-23 | 13.0 | 5.5 | 12.0+ |
| [v0.13.3](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0133) | 2021-08-09 | 12.5 | 5.4 | 10.0+ |
| [v0.13.2](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0132) | 2021-06-30 | 12.5 | 5.4 | 10.0+ |
| [v0.13.1](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0131) | 2021-06-01 | 12.5 | 5.4 | 10.0+ |
| [v0.13.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0130) | 2021-02-08 | 12.4 | 5.3 | 10.0+ |
| [v0.12.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0120) | 2020-12-30 | 12.2 | 5.3 | 10.0+ |
| [v0.11.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0110) | 2020-12-18 | 12.2 | 5.3 | 10.0+ |
| [v0.10.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#0100) | 2020-11-03 | 12.1 | 5.3 | 10.0+ |
| [v0.9.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE_CN.md#090) | 2020-10-09 | 12.0 | 5.3 | 10.0+ |

## 版权协议

AnyImageKit 基于 MIT 协议进行分发和使用，更多信息参见[协议文件](./LICENSE)。
