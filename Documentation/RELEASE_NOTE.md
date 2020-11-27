# Release Notes

## 0.11.0

### New Features

### Resolved



## 0.10.0

### General

- AnyImageKit is now adapt for the latest iPhone 12/12 Pro series devices.

### New Features

- Core
  - Added `ImageKitDataTrackDelegate` for track page/event, supported page and events can be find [HERE](./DATA_TRACK.md).
- Picker
  - Picker now observe photo library changes on all supported iOS versions and loads library changes automatically.
  - Added preselection mode, set `PickerOptionsInfo.preselectAssets: [String]` to enable preselection.

### Resolved

- Picker
  - Unify the color of the toolbar and navigation bar on selection.
  - Fixed an issue that picker reload photo library multiple times.
  - Fixed an issue that lose progress when fetch video from iCloud in iOS 14.
  - Now open the album will locate the current album.
- Editor
  - Fixed an issue that the crop box going black in iOS 11.
  - When entering text in the editor, `return` key now shows as done instead of return.
- Capture
  - Fixed an issue that the focus frame going black in iOS 11.

### Incompatible changes

- Picker/Editor/Capture now has an empty initialization method `required init() ` and has changed the old method from `required init(options: ...) ` to `convenience init(options: ...) `, to make it easier to subclass related items.
- The `delegate` access control of Picker/Editor/Capture changes to `open` instead of `open private(set)` and can be changed after initialization.
- The `update(options: ...)` method has been added in Picker/Editor/Capture, which should call before present.

## 0.9.0

### General

- AnyImageKit build with Xcode 12 instead of Xcode 11.
- AnyImageKit use Swift Package Manager as dependency instead of Cocoapods.
- AnyImageKit support Swift Package Manager.

### New Features

- Picker
  - Adapt iOS 14 “Limited Photos Library” mode.
- Editor
  - Pen colors support `UIColorWell` in iOS 14.

### BREAKING CHANGE

We have modified the callback methods of the three modules to prepare for the stability of ABI in the future.

#### Picker

```swift
/// Original callback method
func imagePicker(_ picker: ImagePickerController, didFinishPicking assets: [Asset], useOriginalImage: Bool)
/// New callback method
/// PickerResult contains assets and useOriginalImage property
func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult)
```

#### Editor

```swift
/// Original callback method
func imageEditor(_ editor: ImageEditorController, didFinishEditing mediaURL: URL, type: MediaType, isEdited: Bool)
/// New callback method
/// EditorResult contains mediaURL, type and isEdited property
func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult)
```

#### Capture

```swift
/// Original callback method
func imageCapture(_ capture: ImageCaptureController, didFinishCapturing mediaURL: URL, type: MediaType)
/// New callback method
/// CaptureResult contains mediaURL and type property
func imageCapture(_ capture: ImageCaptureController, didFinishCapturing result: CaptureResult)
```

#### Other BREAKING CHANGE

- Editor
  - For support `UIColorWell` feature, the ` penColors` property has been changed from `[UIColor]` to `[EditorPenColorOption]`.

### Resolved

- Picker
  - Fixed a bug that not clearing selected assets when switching albums.
  - Fixed a bug that the status of the toolbar at the bottom not update when switching albums.
  - Fixed a bug that the "camera item" appears repeatedly when switching albums.
- Editor
  - Fixed an issue that the global breakpoint will be triggered at the first startup.
  - Fixed a bug that incomplete color display when input text.

### Known Issues

- Remove from support as Xcode 12.0 can't support Mac Catalyst 14.0 features.





