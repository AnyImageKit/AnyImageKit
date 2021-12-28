# Capture 使用说明

本节我们将会详细介绍 `Capture` 中每个配置项的作用。



## 调用/回调说明

`ImageCaptureController` 的使用方法与其他两个组件类似。

```swift
let controller = ImageCaptureController(options: .init(), delegate: self)
present(controller, animated: true, completion: nil)
```

接下来要实现 `ImageCaptureControllerDelegate` 中的两个代理方法。

```swift
/// 取消拍摄（该方法有默认实现，可以省略）
func imageCaptureDidCancel(_ capture: ImageCaptureController) {
    capture.dismiss(animated: true, completion: nil)
}

/// 完成拍摄
/// - Parameters:
///   - capture: 采集器
///   - result: 返回结果对象，内部包含资源 URL、资源类型
func imageCapture(_ capture: ImageCaptureController, didFinishCapturing result: CaptureResult) {
    capture.dismiss(animated: true, completion: nil)
    // 处理你的业务逻辑
}
```

**注意：** 在两个代理方法中，都需要手动 `dismiss` 控制器。



## 配置项说明

### TintColor (UIColor)

`tintColor` 是主题色，默认为绿色。



### MediaOptions (CaptureMediaOption)

`mediaOptions` 是允许使用的媒体类型，默认为 `[.photo, .video]`。

```swift
struct CaptureMediaOption: OptionSet {
    /// 拍摄照片
    static let photo = CaptureMediaOption(rawValue: 1 << 0)
    /// 录制视频
    static let video = CaptureMediaOption(rawValue: 1 << 1)
}
```

当同时支持拍照和录像时，单击为拍照，长按为录像。



### PhotoAspectRatio (CaptureAspectRatio)

`photoAspectRatio` 是照片拍摄比例，默认为 `.ratio4x3`。

```swift
enum CaptureAspectRatio: Equatable {   
    case ratio1x1
    case ratio4x3
    case ratio16x9
}
```



### PreferredPositions ([CapturePosition])

`preferredPositions` 是允许使用的摄像头，默认为 `[.back, .front]`。

```swift
enum CapturePosition: RawRepresentable, Equatable {    
    case front
    case back
}
```

默认使用第一个选项的摄像头，即默认使用后置摄像头。



### FlashMode (CaptureFlashMode)

`flashMode` 是闪光灯模式，默认为 `.off`。

```swift
enum CaptureFlashMode: RawRepresentable, Equatable {    
    case auto
    case on
    case off
}
```



### VideoMaximumDuration (TimeInterval)

`videoMaximumDuration` 是允许视频拍摄的最大时间，默认为 20（秒）。



### PreferredPresets ([CapturePreset])

`preferredPresets` 是相机预设的分辨率，默认为 `[.hd1920x1080_60, .hd1280x720_60, .hd1920x1080_30, .hd1280x720_30]`。即从 `1920*1080@60` 开始查找设备支持的最佳分辨率。

```swift
struct CapturePreset: Equatable {
    let width: Int32
    let height: Int32
    let frameRate: Int32
}
```



### EditorPhotoOptions (EditorPhotoOptionsInfo)

`editorPhotoOptions` 是 `Editor` 模块图片编辑的配置项，你可以在[Editor使用说明](https://github.com/AnyImageKit/AnyImageKit/wiki/Editor%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)中查看详细的介绍。



### EditorVideoOptions (EditorVideoOptionsInfo)

`editorVideoOptions` 是 `Editor` 模块视频编辑的配置项，你可以在[Editor使用说明](https://github.com/AnyImageKit/AnyImageKit/wiki/Editor%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)中查看详细的介绍。



## 注意事项

由于 iPadOS 拥有旋转的特性，所以在 iPadOS 中，我们将使用系统的 `UIImagePickerController` 替换我们自定义的相机，因此部分属性将会失效，我们会在将来适配 iPadOS 尽情期待。
