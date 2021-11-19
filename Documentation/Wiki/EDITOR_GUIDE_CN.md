# Editor 使用说明

本节我们将会详细介绍 `Editor` 中每个配置项的作用，以及一些公开方法。



## 调用/回调说明

`ImageEditorController` 有两组初始化方法，分别对应图片编辑器和视频编辑器。

### Photo Editor

```swift
let controller = ImageEditorController(photo: image, options: .init(), delegate: self)
present(controller, animated: true, completion: nil)
```

### Video Editor

```swift
let controller = ImageEditorController(video: fileURL, placeholderImage: nil, options: .init(), delegate: self)
present(controller, animated: true, completion: nil)
```

### 回调

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



## 初始化

### Photo Editor 初始化

在图片编辑器的初始化方法中，需要传入 `photo` 参数，其参数类型为 `EditorPhotoResource`。

`EditorPhotoResource` 是一个协议，符合这个协议的类，都可以作为参数传入，协议声明如下：

```swift
protocol EditorPhotoResource {
    func loadImage(completion: @escaping (Result<UIImage, AnyImageError>) -> Void)
}
```

目前有 3 个类遵守 `EditorPhotoResource` 协议：

- UIImage
- PHAsset
- URL（仅限于本地 URL）



### Video Editor 初始化

视频编辑器的初始化方法也是类似，需要传入 `video` 参数，类型为 `EditorVideoResource`。

`EditorVideoResource` 协议声明 如下：

```swift
public protocol EditorVideoResource {
    func loadURL(completion: @escaping (Result<URL, AnyImageError>) -> Void)
}
```

目前有 2 个类遵守 `EditorVideoResource` 协议：

- PHAsset
- URL（仅限于本地 URL）



## Photo Editor 配置项说明

### TintColor (UIColor)

`tintColor` 是主题色，默认为绿色。



### ToolOptions ([EditorPhotoToolOption])

`toolOptions` 是开放哪些编辑功能，默认为 `[.pen, .text, .crop, .mosaic]`。

```swift
enum EditorPhotoToolOption: Equatable, CaseIterable {
    /// 画笔
    case pen
    /// 文字
    case text
    /// 裁剪
    case crop
    /// 马赛克
    case mosaic
}
```



### PenColors ([EditorPenColorOption])

`penColors` 是画笔的颜色，默认为 `[white, black, red, yellow, green, blue, purple]`。

```swift
enum EditorPenColorOption: Equatable {
    /// 自定义颜色
    case custom(color: UIColor)
    /// UIColorWell
    @available(iOS 14.0, *)
    case colorWell(color: UIColor)
}
```

在 iOS 14 及以上版本中，我们将最后一个 `purple` 的类型由 `custom` 改为 `colorWell`。

`UIColorWell` 是 iOS 14 新出的 API，可以让用户自定义选择颜色。

`penColors` 最多允许设置 7 个颜色。



### DefaultPenIndex (Int)

`defaultPenIndex` 是默认选择画笔的下标，默认为 2，即默认选择红色。



### PenWidth (CGFloat)

`penWidth` 是画笔宽度，默认为 5.0。



### MosaicOptions ([EditorMosaicOption])

`mosaicOptions` 是马赛克的类型，默认为 `[.default, .colorful]`。

```swift
enum EditorMosaicOption: Equatable {
    /// 默认马赛克
    case `default`
    /// 自定义马赛克
    case custom(icon: UIImage?, mosaic: UIImage)
    
    static var colorful: EditorMosaicOption {
        return .custom(icon: nil, mosaic: BundleHelper.image(named: "CustomMosaic")!)
    }
}
```

默认类型的马赛克的模糊度有属性可以调整，后面会介绍。

自定义类型的马赛克可以传入马赛克的图片。

马赛克的原理其实就是在图片上再叠加一层透明的马赛克图片，待用户手势滑过后，将滑过的部分显示出来，就达到了马赛克的效果了。所以基于这个的原理，我们可以通过 `.custom` 自定义马赛克的样式。

另外如果使用了 `.default` 样式的马赛克一定要注意图片的大小，如果图片太大会导致生成马赛克图片的时间要很久，导致用户体验下降。



### DefaultMosaicIndex (Int)

`defaultMosaicIndex` 是默认选择马赛克的下标，默认为 0。



### MosaicWidth (CGFloat)

`mosaicWidth` 是马赛克线条宽度，默认为 15。



### MosaicLevel (Int)

`mosaicLevel` 是马赛克模糊度，仅用于默认马赛克样式，默认为 30。



### TextColors ([EditorTextColor])

`textColors` 是输入文本的颜色，默认为 `[white, black, red, yellow, green, blue, purple]`。

```swift
struct EditorTextColor: Equatable {
    /// 主色
    let color: UIColor
    /// 辅色
    let subColor: UIColor
    /// 在非高亮的样式下，阴影的样式
    let shadow: Shadow?
}
```

输入文本的功能效果与微信相似，有非高亮和高亮两种状态，所以需要两个颜色。

- 非高亮：无背景色，文本颜色使用 `color`。
- 高亮：背景色使用 `color`，文本颜色使用 `subColor`。



### TextFont (UIFont)

设置输入文本时的字体，默认为 `.systemFont(ofSize: 32, weight: .bold)`。



### IsTextSelected (Bool)

设置输入文本时默认的样式，默认为 `true`。



### CalculateTextLastLineMask (Bool)

计算输入文本时最后一行的宽度，用于是否展示遮罩，默认为 `true`。



### CropOptions ([EditorCropOption])

`cropOptions` 是裁剪尺寸，默认为 `[.free, 1:1, 3:4, 4:3, 9:16, 16:9]`。

```swift
enum EditorCropOption: Equatable {
    /// 自由裁剪
    case free
    /// 自定义裁剪 宽高比
    case custom(w: UInt, h: UInt)
}
```



### RotationDirection (EditorRotationDirection)

`rotationDirection` 是旋转功能的旋转方向，默认为 `.turnLeft`

```swift
enum EditorRotationDirection: Equatable {
    /// 关闭旋转
    case turnOff
    /// 向左旋转
    case turnLeft
    /// 向右旋转
    case turnRight
}
```

当打开旋转功能时，`cropOptions` 自定义的裁剪尺寸要求成对出现。

比如之前设置 `cropOptions = [3:4, 9:16]`，之后需要增加 4:3, 16:9 这两种情况。

因为当用户指定裁剪比例为 3:4 时，旋转之后比例会变成 4:3，所以要求自定义的裁剪尺寸要成对出现。



### CacheIdentifier (String)

`cacheIdentifier` 是缓存标识符，默认为 `""`，即默认不缓存。

如果设置了这个配置项，每次编辑的行为都会被记录下来，下次再进入 `Editor` 会读取编辑记录并复原。如果你试过从 `Picker → Editor` 进行编辑，退出再进入编辑，你会发现上次编辑过的内容是可以撤销的，这就是编辑记录缓存的效果。

**注意**：由于缓存会写入磁盘，所以缓存字符串中不允许包含 `/` 字符。



#### 删除编辑记录缓存

删除缓存需要使用 `ImageEditorCache` 类中的静态方法，我们提供了两种删除缓存的方法：

```swift
final class ImageEditorCache {
    static func clearDiskCache(id: String) // 删除指定编辑记录缓存
    static func clearImageEditorCache()    // 删除所有编辑记录缓存
}

// 调用
ImageEditorCache.clearDiskCache("cache_id")
ImageEditorCache.clearImageEditorCache()
```





## Video Editor 配置项说明

### TintColor (UIColor)

`tintColor` 是主题色，默认为绿色。



### ToolOptions ([EditorVideoToolOption])

`toolOptions` 是开放哪些编辑功能，默认为 `[.clip]`。

```swift
enum EditorPhotoToolOption: Equatable, CaseIterable {
    /// 剪辑
    case clip
}
```



## 注意事项

由于 iPadOS 拥有旋转的特性，所以在 iPadOS 中，当发生旋转时，我们会关闭编辑器。
