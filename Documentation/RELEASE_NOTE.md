# Release Notes

## 0.15.1

### Resolved

- Picker
  - Crash that UI API not call on main thread.

## 0.15.0

### General

- Support back to iOS 12 (May drop iOS 12 in next version). ([#153](https://github.com/AnyImageKit/AnyImageKit/pull/153))

### Resolved

- Fix few issue on iPad. ([#158](https://github.com/AnyImageKit/AnyImageKit/pull/158))
- Fix HUD and Toast sometimes could not disappear correctly. ([#161](https://github.com/AnyImageKit/AnyImageKit/pull/161))

- Picker
  - When user deletes photos in system Photos app and back to AnyImagePicker, it may crash. ([#157](https://github.com/AnyImageKit/AnyImageKit/pull/157))
- Editor
  - Upside down rotation dose not work. ([#156](https://github.com/AnyImageKit/AnyImageKit/pull/156))
- Capture
  - Capturing with Matal may crash. ([#160](https://github.com/AnyImageKit/AnyImageKit/pull/160))

## 0.14.6

### Fix

- Set SPM target platforms v13.

## 0.14.5

### New Features

- Use Xcode 13.4.1/Xcode 14.0 beta2.
- Set framework minimum deployment target to 13.0.

### Resolved

- Picker
  - Fix the issue that sort by adding time instead of creation time.

## 0.14.4

### Resolved

- Picker
  - Fix can not add more photos when limit permission mode.([#144](https://github.com/AnyImageKit/AnyImageKit/pull/144))

## 0.14.3

### Resolved

- Picker
  - Fix the issue that disable rule is not checked when selecting photos after taking photos.
  - Fix asset collection view will be offset when `contentInsetAdjustmentBehavior` is modified globally.

- Editor
  - Fix the issue that image will be wrong after crop when tool option only has crop option.([#133](https://github.com/AnyImageKit/AnyImageKit/pull/133))

## 0.14.2

### Resolved

- Picker
  - Fix when using Xcode 13.2+, main thread will be stuck for 15 seconds when requesting to register photo library observer before authorization.([#130](https://github.com/AnyImageKit/AnyImageKit/pull/130))
  - Fix shared albums cannot be select in picker, add a new option `.shared` for `PickerAlbumOption`.([#129](https://github.com/AnyImageKit/AnyImageKit/pull/129)) ([#131](https://github.com/AnyImageKit/AnyImageKit/pull/131))

## 0.14.1

### Resolved

- Picker
  - Crash after take photo in iOS 14 or later.

## 0.14.0

### New Features

- Editor
  - Added `rotationDirection` enumeration. Can rotate the image when cropping. ([#100](https://github.com/AnyImageKit/AnyImageKit/pull/100))
  - Added `textFont` UIFont value. Can customize font of input text.
  - Added `isTextSelected` boolean value. Set default style of input text.
  - Added `calculateTextLastLineMask` boolean value. Calculate the width of the last line of the input text to show mask layer.
  - Added input text border.
  - Added the shadow of input text.

### Improved

- All modules
  - `Theme` can customize color, icon, text, label and button. ([#104](https://github.com/AnyImageKit/AnyImageKit/pull/104))
  - `Data track` added more events, supported page and events can be find [HERE](./DATA_TRACK.md).
- Picker
  - `AssetDisableCheckRule` support more complex scene. ([#96](https://github.com/AnyImageKit/AnyImageKit/pull/96))
- Editor
  - Improved the response area of input text.

### Resolved

- Picker
  - Try to fix that quick click on done button will trigger the delegate several times. ([#110](https://github.com/AnyImageKit/AnyImageKit/pull/110))
  - Fixed `GIF/Live Photo` will show edit button.
  - Before iOS 14, Picker used the wrong index when selecting asset after take photos in desc sort mode.
- Editor
  - Crush when cropping video. ([#111](https://github.com/AnyImageKit/AnyImageKit/pull/111))
  - In the specified crop option, the crop rect may not move.
  - The UITextView may scroll when enter input text.

### Other

- Added `API Tests` to compare API between different versions.

## 0.13.5

### Resolved

- Fix Xcode 12 can not build.

## 0.13.4

### New Features

- Use Xcode 13.0 and Kingfisher 7.0.0 
- Set framework minimum deployment target to 12.0 

## 0.13.3

### New Features

- Added `Portuguese(Brazil) (pt-BR)` internationalization support.([#106](https://github.com/AnyImageKit/AnyImageKit/pull/106))

## 0.13.2

### Resolved

- Fix Xcode 13 beta can not build bug.

## 0.13.0

### General

- AnyImageKit now support `resource_bundles` for CocoaPods.([#79](https://github.com/AnyImageKit/AnyImageKit/pull/79))
- Added `Turkish (tr)` internationalization support.([#70](https://github.com/AnyImageKit/AnyImageKit/pull/70))

### New Features

- Editor
  - The output workflow has been refactored so that editing now does not reduce the resolution of the original image.([#67](https://github.com/AnyImageKit/AnyImageKit/pull/67))

### Resolved

- Core
  - Fixed the issue that `AnyImageError.invalidExportPreset` is thrown when setting HEVC/H.265 output with devices below A10 chip, and the unsupported devices will be downgraded to AVC/H.264 solution automatically.([#75](https://github.com/AnyImageKit/AnyImageKit/pull/75))
  - Fixed the issue that the status bar is not hidden correctly on iPhone8/8 Plus and older device.([#78](https://github.com/AnyImageKit/AnyImageKit/pull/78))
- Capture
  - Fixed the issue that Metal resource files were not copied when using CocoaPods as a static library dependency.([#81](https://github.com/AnyImageKit/AnyImageKit/pull/81))

## 0.12.0

### New Features

- Picker
  - Added the `selectionTapAction` enumeration. The action after tapping the asset on selection view depends on this enumeration. ([#59](https://github.com/AnyImageKit/AnyImageKit/issues/59))
  - Added the `saveEditedAsset` boolean value. Determines whether the Picker save edited assets.

### Resolved

- Picker
  - Fixed the issue that Picker would crash by array index out of range when `orderByDate = DESC`. ([#65](https://github.com/AnyImageKit/AnyImageKit/issues/65))
  - Fixed the issue that the `Preview` button cannot be used sometimes.

### BREAKING CHANGE

- Picker remove `quickPick` boolean value, please use `selectionTapAction` enumeration instead.

## 0.11.0

### General

- AnyImageKit now support Mac Catalyst again.

### New Features

- Picker
  - Add a new protocol `AssetDisableCheckRule` to allow custom asset disable check rules. AnyImageKit contains a buildin implement  `VideoDurationDisableCheckRule` to support video duration check.
- Editor
  - Auto set `.modalPresentationStyle = .fullScreen` in `ImageEditorController`'s init function.
- Capture
  - Auto set `.modalPresentationStyle = .fullScreen` in `ImageCaptureController`'s init function.

### Resolved

- Picker
  - Fixed a memory leak when use `NSDiffableDataSourceSnapshot` in iOS 14 and later.
  - Fixed the progress display when selected multiple assets which need download from iCloud.
  - The maximum zoom scale of the photo during preview is changed from fixed value to calculation based on image size.
- Editor
  - The maximum zoom scale of the photo during editor is changed from fixed value to calculation based on image size.

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





