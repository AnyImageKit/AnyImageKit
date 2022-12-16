# 更新日志

## 0.15.1

### 修复

- Picker
  - 修复未再主线程调用 UI 问题。

## 0.15.0

### 通用

- 最低部署版本调整为 iOS 12.0（后续版本会抛弃 iOS 12.0）。 ([#153](https://github.com/AnyImageKit/AnyImageKit/pull/153))

### 修复

- 修复 iPad 上一些问题。 ([#158](https://github.com/AnyImageKit/AnyImageKit/pull/158))
- 修复 HUD & Toast 有时无法消失的问题。 ([#161](https://github.com/AnyImageKit/AnyImageKit/pull/161))

- Picker
  - 修复当用户在系统相册删除图片后，再返回 AnyImageKit 可能会崩溃的问题。 ([#157](https://github.com/AnyImageKit/AnyImageKit/pull/157))
- Editor
  - 修复旋转 180 度不生效的问题。 ([#156](https://github.com/AnyImageKit/AnyImageKit/pull/156))
- Capture
  - 修复 Matal 会崩溃的问题。 ([#160](https://github.com/AnyImageKit/AnyImageKit/pull/160))

## 0.14.6

### 修复

- SPM 部署版本调整为 v13。

## 0.14.5

### 新增

- 使用 Xcode 13.4.1/Xcode 14.0 beta2。
- 最低部署版本调整为 13.0。

### 修复

- Picker
  - 修复通过创建时间而不是添加时间进行排序的问题。

## 0.14.4

### 修复

- Picker
  - 修复相册权限为选中的照片时，无法展示添加更多照片提示的问题。([#144](https://github.com/AnyImageKit/AnyImageKit/pull/144))

## 0.14.3

### 修复

- Picker
  - 修复拍照之后没有检查资源是否符合禁用规则就进行了选中。
  - 修复 `contentInsetAdjustmentBehavior` 被业务方全局替换后，视图出现偏移的问题。

- Editor
  - 修复当编辑选项仅裁剪时，输出了错误的图片。([#133](https://github.com/AnyImageKit/AnyImageKit/pull/133))

## 0.14.2

### 修复

- Picker
  - 修复使用 Xcode 13.2+ 时，未授权时请求注册相册观察者会卡住主线程 15 秒的问题。([#130](https://github.com/AnyImageKit/AnyImageKit/pull/130))
  - 修复无法选择共享相册的问题，`PickerAlbumOption` 添加了一个 `.shared` 的选项。([#129](https://github.com/AnyImageKit/AnyImageKit/pull/129)) ([#131](https://github.com/AnyImageKit/AnyImageKit/pull/131))

## 0.14.1

### 修复

- Picker
  - 修复 iOS 14 及以上版本，拍照后会闪退的问题。

## 0.14.0

### 新增

- Editor
  - 新增 `rotationDirection` 枚举字段，支持在裁剪时进行旋转。([#100](https://github.com/AnyImageKit/AnyImageKit/pull/100))
  - 新增 `textFont` 字段，用于设置输入文本时的字体。
  - 新增 `isTextSelected` 布尔字段，用于设置默认字体样式。
  - 新增 `calculateTextLastLineMask` 布尔字段，用于输入文本时是否计算最后一行宽度。
  - 文本边框回归。
  - 文本在纯色样式下增加阴影配置。

### 优化

- 所有模块
  - `Theme` 可以自定义颜色/图标/文本，可以对`Label/Button` 进行定制。 ([#104](https://github.com/AnyImageKit/AnyImageKit/pull/104))
  - `Data track` 支持更多事件，已支持的页面和事件可以在 [这里](./DATA_TRACK.md) 找到。
- Picker
  - `AssetDisableCheckRule` 支持更复杂的业务场景。 ([#96](https://github.com/AnyImageKit/AnyImageKit/pull/96))
- Editor
  - 扩大文本响应区域。

### 修复

- Picker
  - 尝试修复快速点击完成按钮会多次触发回调。 ([#110](https://github.com/AnyImageKit/AnyImageKit/pull/110))
  - `GIF/Live Photo` 会展示编辑按钮。
  - iOS 14 之前版本，在倒序排序模式下，拍照后会导致资源下标错乱。
- Editor
  - 编辑视频时闪退。 ([#111](https://github.com/AnyImageKit/AnyImageKit/pull/111))
  - 在指定裁剪比例模式下，裁剪框可能会无法移动。
  - 输入文本时，文本框可能会滚动。

### 其他

- 增加 `API Tests`，用于比较不同版本间 API 的差异。

## 0.13.5

### 修复

- 修复无法在 Xcode 12 编译的问题。

## 0.13.4

### 新增

- 使用 Xcode 13.0 和 Kingfisher 7.0.0。
- 调整最低部署版本为 iOS 12.0+ 以解决 Xcode 编译异常的问题。

## 0.13.3

### 新增

- 新增葡萄牙语-巴西 `Portuguese(Brazil) (pt-BR)` 国际化支持。([#106](https://github.com/AnyImageKit/AnyImageKit/pull/106))

## 0.13.2

### 修复

Xcode 13 beta 无法编译错误。([#95](https://github.com/AnyImageKit/AnyImageKit/issues/95))

## 0.13.0

### 通用

- 支持 CocoaPods `resource_bundles` 特性。([#79](https://github.com/AnyImageKit/AnyImageKit/pull/79))
- 新增土耳其语 `Turkish (tr)` 国际化支持。([#70](https://github.com/AnyImageKit/AnyImageKit/pull/70))

### 新增

- Editor
  - 重构了输出模块，现在编辑后不会降低原图的分辨率。([#67](https://github.com/AnyImageKit/AnyImageKit/pull/67))

### 修复

- Core
  - 修复使用 A10 以下设备设置 HEVC/H.265 输出时抛出 AnyImageError.invalidExportPreset 的问题，不支持的设备会自动降级到 AVC/H.264 方案。([#75](https://github.com/AnyImageKit/AnyImageKit/pull/75))
  - 修复状态栏在非全面屏上隐藏不正确的问题。([#78](https://github.com/AnyImageKit/AnyImageKit/pull/78))
- Capture
  - 修复使用 CocoaPods 作为静态库依赖时不会拷贝 Metal 资源文件的问题。([#81](https://github.com/AnyImageKit/AnyImageKit/pull/81))

## 0.12.0

### 新增

- Picker
  - 新增 `selectionTapAction` 枚举字段，用于在资源列表页面点击资源后的动作。([#59](https://github.com/AnyImageKit/AnyImageKit/issues/59))
  - 新增 `saveEditedAsset` 布尔字段，用于完成选择后是否保存编辑过的资源。

### 修复

- Picker
  - 修复 `DESC` 排序时，获取数据错误和数组越界问题。([#65](https://github.com/AnyImageKit/AnyImageKit/issues/65))
  - 修复 `预览` 按钮有时无法使用的问题。

### 不兼容变更

- Picker 移除 `quickPick` 字段，请使用新字段 `selectionTapAction` 代替。

## 0.11.0

### 通用

- 重新支持 Mac Catalyst

### 新增

- Picker
  - 新增 `AssetDisableCheckRule`，允许自定义资源禁用规则/文案，框架已自带 `VideoDurationDisableCheckRule` 实现按最大/最小时长过滤视频。
- Editor
  - 将 `.modalPresentationStyle = .fullScreen` 移至 `ImageEditorController` 的初始化方法中，调用者无需重复设置。
- Capture
  - 将 `.modalPresentationStyle = .fullScreen` 移至 `ImageCaptureController` 的初始化方法中，调用者无需重复设置。

### 修复

- Picker
  - 修复 `NSDiffableDataSourceSnapshot` 存在内存泄漏的问题。
  - 修复选中多个需要从 iCloud 下载的资源时进度不正确的问题。
  - 预览时图片最大缩放比例从固定值改为根据图片大小计算。
- Editor
  - 编辑时图片最大缩放比例从固定值改为根据图片大小计算。

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
