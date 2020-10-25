# 更新日志

## 0.10.0

### 新增

- Core
  - 添加 `ImageKitDataTrackDelegate` 用以数据打点，已支持的页面和事件可以在 [这里](./DATA_TRACK.md) 找到

## 0.9.0

### 构建

- 项目构建从 Xcode 11 升级到 Xcode 12。
- 项目第三方依赖从 Cocoapods 变更为 Swift Package Manager。
- 项目支持使用 Swift Package Manager 引入。

### 新增

- Picker
  - 适配 iOS 14  “Limited Photos Library” 模式
- Editor
  - 画笔在 iOS 14 中支持 `UIColorWell`。

### 不兼容变更

为了将来 ABI 稳定做准备，我们修改了三个模块的回调方法。

#### Picker

```swift
/// 原回调方法
func imagePicker(_ picker: ImagePickerController, didFinishPicking assets: [Asset], useOriginalImage: Bool)
/// 新回调方法
/// PickerResult 中包含 assets、useOriginalImage 字段
func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult)
```

#### Editor

```swift
/// 原回调方法
func imageEditor(_ editor: ImageEditorController, didFinishEditing mediaURL: URL, type: MediaType, isEdited: Bool)
/// 新回调方法
/// EditorResult 中包含 mediaURL、type、isEdited 字段
func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult)
```

#### Capture

```swift
/// 原回调方法
func imageCapture(_ capture: ImageCaptureController, didFinishCapturing mediaURL: URL, type: MediaType)
/// 新回调方法
/// CaptureResult 中包含 mediaURL、type 字段
func imageCapture(_ capture: ImageCaptureController, didFinishCapturing result: CaptureResult)
```

#### 其他不兼容变更

- Editor
  - 配置项中 `penColors` 属性为了支持 `UIColorWell` 特性，由 `[UIColor]` 变更为 `[EditorPenColorOption]`。

### 修复

- Picker
  - 修复切换相册没有清理缓存数据的问题。
  - 修复切换相册底部工具栏状态没有更新的问题。
  - 修复切换相册导致“拍照” Item 重复出现的问题。
- Editor
  - 修复首次启动会触发全局断点的问题。
  - 修复输入文本时颜色展示不全的问题。

### 已知问题

- 由于 Xcode 12.0 不能支持 Mac Catalyst 14.0 的功能，因此从支持中移除。