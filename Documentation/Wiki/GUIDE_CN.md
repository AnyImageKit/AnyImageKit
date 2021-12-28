## 功能概览

### Picker

- [x] UI 外观支持浅色/深色/自动 (iOS 13.0+)
- [x] 默认主题与微信相似
- [x] 支持多选/混合内容选择
- [x] 支持的媒体类型:
  - [x] Photo
  - [x] GIF
  - [x] Live Photo
  - [x] Video
- [x] 支持在选择时直接拍照
- [x] 多平台支持
  - [x] iOS
  - [x] iPadOS
  - [ ] Mac Catalyst (技术预览版，暂不支持编辑。由于 Xcode 12.0 不能支持 Mac Catalyst 14.0 的功能，因此从支持中移除。)

### Editor

- [ ] 图片编辑
  - [x] 涂鸦
  - [ ] 表情
  - [x] 文字
  - [x] 裁剪
  - [x] 马赛克
  - [ ] 旋转
  - [ ] 滤镜
  
- [ ] 视频编辑
  - [x] 裁剪
  - [ ] 文字
  - [ ] 背景音乐
  - [ ] 旋转
  
- [ ] 多平台支持
  - [x] iOS
  - [x] iPadOS
  - [ ] Mac Catalyst

### Capture

- [ ] 拍摄类型
  - [x] 照片
  - [x] 视频
  - [ ] GIF
  - [ ] LivePhoto



## 使用方式

### Picker

`ImagePickerController` 的使用方式与 `UIImagePickerController` 非常类似。

首先我们用三行代码创建并推出选择器。

```swift
let controller = ImagePickerController(delegate: self)
controller.modalPresentationStyle = .fullScreen
present(controller, animated: true, completion: nil)
```

接下来要实现 `ImagePickerControllerDelegate` 中的两个代理方法。

```swift
/// 取消选择（该方法有默认实现，可以省略）
func imagePickerDidCancel(_ picker: ImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
}

/// 完成选择
/// - Parameters:
///   - picker: 图片选择器
///   - result: 返回结果对象，内部包含所选中的图片资源
func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
    picker.dismiss(animated: true, completion: nil)
    let images: [UIImage] = result.assets.map{ $0.image }
    // 处理你的业务逻辑
}
```

**注意：** 在两个代理方法中，都需要手动 `dismiss` 控制器。



### Editor

`ImageEditorController` 有两组初始化方法，分别对应图片编辑器和视频编辑器。

#### Photo Editor

```swift
let controller = ImageEditorController(photo: image, delegate: self)
present(controller, animated: true, completion: nil)
```

#### Video Editor

```swift
let controller = ImageEditorController(video: fileURL, delegate: self)
present(controller, animated: true, completion: nil)
```

图片编辑和视频编辑的回调都是通过 ` ImageEditorControllerDelegate` 代理返回的。

```swift
/// 取消编辑（该方法有默认实现，可以省略）
func imageEditorDidCancel(_ editor: ImageEditorController) {
    editor.dismiss(animated: true, completion: nil)
}

/// 完成编辑
/// - Parameters:
///   - editor: 编辑器
///   - result: 返回结果对象，内部包含资源 URL、资源类型等
func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
    editor.dismiss(animated: true, completion: nil)
    // 处理你的业务逻辑
}
```

**注意：** 在两个代理方法中，都需要手动 `dismiss` 控制器。



### Capture

`ImageCaptureController` 的使用方法与上述两个组件类似。

```swift
let controller = ImageCaptureController(delegate: self)
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



## 使用要求

- iOS 10.0+
- Swift 5.3+
- Xcode 12.0+



## 准备工作

按需在你的 Info.plist 中添加以下键值:

| Key                                              | 模块    | 备注                                                         |
| ------------------------------------------------ | ------- | ------------------------------------------------------------ |
| NSPhotoLibraryUsageDescription                   | Picker  | 允许访问相册                                                 |
| NSPhotoLibraryAddUsageDescription                | Picker  | 允许保存图片至相册                                           |
| PHPhotoLibraryPreventAutomaticLimitedAccessAlert | Picker  | 设置为 `YES` iOS 14+ 以禁用自动弹出添加更多照片的弹框(Picker 已适配 Limited 功能，可由用户主动触发，提升用户体验) |
| NSCameraUsageDescription                         | Capture | 允许使用相机                                                 |
| NSMicrophoneUsageDescription                     | Capture | 允许使用麦克风                                               |



## 下一步

[安装说明](https://github.com/AnyImageKit/AnyImageKit/wiki/%E5%AE%89%E8%A3%85%E8%AF%B4%E6%98%8E)
