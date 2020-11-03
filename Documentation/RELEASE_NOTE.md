# Release Notes

## 0.10.0

### New Features

- Core
  - Add `ImageKitDataTrackDelegate` for track page/event, supported page and event can be find [HERE](./DATA_TRACK.md).
- Picker
  - Picker now observe photo library changes on all supported iOS versions and automatically loads add/remove changes.
  - Added preselection mode, set `PickerOptionsInfo.preselectAssets: [String]` to enable preselection.

### Fix

- Picker
  - Unify the color of the toolbar and navigation bar on selection.
  - Better compatibility with iOS 14 "Limited Photos Library" mode.
  - Fix issue with video loading in iOS 14.
  - Now locate to the current album when opening album selection.
- Editor
  - Fix the issue with the crop box going black in iOS 11.
  - When entering text in the editor, return now shows as done instead of a line break.
- Capture
  - Fix the issue with the focus frame going black in iOS 11.

### Incompatible changes

- Picker/Editor/Capture now has an empty initialization method `required init() ` and has changed the old func from `required init(options: ...) ` to `convenience init(options: ...) `, to make it easier to subclass related items.
- The `delegate` of Picker/Editor/Capture is now open and can be changed after initialization.
- The `update(options: ...)' method has been added in Picker/Editor/Capture, which should call before present.

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





