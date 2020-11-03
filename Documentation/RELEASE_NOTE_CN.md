# 更新日志

## 0.10.0

### 通用

- 已适配最新的 iPhone 12/12 Pro 系列设备。

### 新增

- Core
  - 添加 `ImageKitDataTrackDelegate` 用以数据打点，已支持的页面和事件可以在 [这里](./DATA_TRACK.md) 找到。
- Picker
  - Picker 现在会在所有支持的 iOS 版本上检测相册的变化，自动加载新增/删除变更。
  - 新增预选模式，设置 `PickerOptionsInfo.preselectAssets: [String]` 以实现预选。

### 修复

- Picker
  - 统一选择时工具栏与导航栏的颜色。
  - 更好的兼容 iOS 14 “Limited Photos Library” 模式。
  - 修复 iOS 14 中，视频加载的问题。
  - 打开相册选择时，现在会定位到当前的相册。
- Editor
  - 修复 iOS 11 中，裁剪框变黑的问题。
  - 现在在编辑器中输入文字时，return 会显示为完成，而非换行。
- Capture
  - 修复 iOS 11 中，对焦框变黑的问题。

### 不兼容变更

- Picker/Editor/Capture 均新增了 `required init()` 的空初始化方法，并将原来的 `required init(options: ...)` 变更为 `convenience init(options: ...)`，方便子类化相关方法以配合老项目接入，已接入的项目保持不变。
- Picker/Editor/Capture 的 `delegate` 均已开放，允许在初始化后变更。
- Picker/Editor/Capture 均新增了 `update(options: ...)` 方法，在 present 前调用。

## 0.9.0

### 通用

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
