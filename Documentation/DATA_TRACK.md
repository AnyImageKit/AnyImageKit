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
| Picker | AlbumPickerViewController | .albumPicker |
| Picker | AssetPickerViewController | .assetPicker |
| Picker | PhotoPreviewController | .photoPreview |
| Editor | PhotoEditorController | .photoEditor |
| Editor | VideoEditorController | .videoEditor |
| Editor | InputTextViewController | .textInput |
| Capture | CaptureViewController | .capture |
| Capture | PadCaptureViewController | .capture |

### Supported Events

| Module | AnyImageEvent | userInfo |
| - | - | - |
| Picker | .takePhoto |  |
| Picker | .takeVideo |  |
| Editor | .photoPen |  |
| Editor | .photoMosaic |  |
| Editor | .photoText |  |
| Editor | .photoCrop |  |
| Capture | .capturePhoto |  |
| Capture | .captureVideo |  |