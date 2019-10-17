# AnyImagePicker

`AnyImagePicker` is an image picker which support for multiple photos, GIFs or videos. [中文说明](./README_CN.md)

## Features

- [x] Light mode, dark mode or auto mode support
- [x] Default theme is similar with Wechat 
- [x] Multiple & mix select support
- [ ] Supported media types:
    - [x] Photo
    - [x] GIF
    - [ ] Live Photo
    - [x] Video
- [ ] Camera
- [ ] Edit image
- [ ] Multiple platform support
    - [x] iOS
    - [ ] iPadOS
    - [ ] Mac Catalyst
    - [ ] macOS
    - [ ] tvOS

## Requirements

- iOS 10.0+
- Xcode 11+
- Swift 5+

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'AnyImagePicker'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

Add this to `Cartfile`

```
github "anotheren/AnyImagePicker"
```

```bash
$ carthage update
```

## Usage

### Quick Start

```swift
import AnyImagePicker

let controller = ImagePickerController(delegate: self)
present(controller, animated: true, completion: nil)

/// ImagePickerControllerDelegate
func imagePicker(_ picker: ImagePickerController, didSelect assets: [Asset], useOriginalImage: Bool) {
    let image = assets.image
    // Your code
}
```

### Fetch content data
```swift
/// Fetch Video URL 
/// - Note: Only for `MediaType` Video
/// - Parameter options: Video URL Fetch Options
/// - Parameter completion: Video URL Fetch Completion
func fetchVideoURL(options: VideoURLFetchOptions = .init(), completion: @escaping VideoURLFetchCompletion)

// Call
asset.fetchVideoURL { (result) in
    // Your code
}
```


## License

AnyImagePicker is released under the MIT license. See [LICENSE](./LICENSE) for details.