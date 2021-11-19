## Data Track

### Usage

Set `trackDelegate` in `AnyImageNavigationController`, which will also be found in `ImagePickerController`, `ImageEditorController`, `ImageCaptureController`

```swift
// AnyImageNavigationController.swift

open weak var trackDelegate: ImageKitDataTrackDelegate?
```

### Supported Pages

| Module | Controller | AnyImagePage |
| - | - | - |
| Picker |  |  |
| Picker | AlbumPickerViewController | .pickerAlbum |
| Picker | AssetPickerViewController | .pickerAsset |
| Picker | PhotoPreviewController | .pickerPreview |
| Editor |  |  |
| Editor | PhotoEditorController | .editorPhoto |
| Editor | VideoEditorController | .editorVideo |
| Editor | InputTextViewController | .editorInputText |
| Capture |  |  |
| Capture | CaptureViewController | .capture |
| Capture | PadCaptureViewController | .capture |

### Supported Events

| Module | AnyImageEvent | userInfo |
| - | - | - |
| Picker |  |  |
| Picker | .pickerCancel |  |
| Picker | .pickerDone | [page: (pickerAsset, pickerPreview)] |
| Picker | .pickerSelect | [isOn: (true, false), page: (pickerAsset, pickerPreview)] |
| Picker | .pickerSwitchAlbum |  |
| Picker | .pickerPreview |  |
| Picker | .pickerEdit |  |
| Picker | .pickerOriginalImage | [isOn: (true, false), page: (pickerAsset, pickerPreview)] |
| Picker | .pickerBackInPreview |  |
| Picker | .pickerLimitedLibrary |  |
| Picker | .pickerTakePhoto |  |
| Picker | .pickerTakeVideo |  |
| Editor |  |  |
| Editor | .editorBack | [page: (editorPhoto, editorVideo)] |
| Editor | .editorDone | [page: (editorPhoto, editorVideo)] |
| Editor | .editorCancel | [page: (editorPhoto, editorVideo)] |
| Editor | .editorPhotoBrushUndo |  |
| Editor | .editorPhotoMosaicUndo |  |
| Editor | .editorPhotoTextSwitch | [isOn: (true, false)] |
| Editor | .editorPhotoCropRotation |  |
| Editor | .editorPhotoCropCancel |  |
| Editor | .editorPhotoCropReset |  |
| Editor | .editorPhotoCropDone |  |
| Editor | .editorPhotoBrush |  |
| Editor | .editorPhotoMosaic |  |
| Editor | .editorPhotoText |  |
| Editor | .editorPhotoCrop |  |
| Editor | .editorVideoPlayPause | [isOn: (true, false)] true=play, false=pause |
| Capture |  |  |
| Capture | .capturePhoto |  |
| Capture | .captureVideo |  |
| Capture | .captureCancel |  |
| Capture | .captureSwitchCamera |  |