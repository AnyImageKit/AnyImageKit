# Release Notes

## 0.10.0

### New Features

- Core
  - Add `ImageKitDataTrackDelegate` for track page/event, supportted page and event can be find [HERE](./DATA_TRACK.md)

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





