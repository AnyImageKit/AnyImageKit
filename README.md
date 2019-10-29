![AnyImagePicker](https://raw.githubusercontent.com/AnyImageProject/AnyImagePicker/master/Resources/TitleMap@2x.png)

[![Travis CI](https://api.travis-ci.org/AnyImageProject/AnyImagePicker.svg?branch=master)](https://travis-ci.com/AnyImageProject/AnyImagePicker)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AnyImagePicker.svg)](https://img.shields.io/cocoapods/v/AnyImagePicker.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/AnyImagePicker.svg?style=flat)](./)
[![License](https://img.shields.io/cocoapods/l/AnyImagePicker.svg?style=flat)](https://raw.githubusercontent.com/AnyImageProject/AnyImagePicker/master/LICENSE)

`AnyImagePicker` is an image picker which support for multiple photos, GIFs or videos. It's written in Swift. 

> [中文说明](./README_CN.md)

## Features

- [x] Light mode, dark mode or auto mode support
- [x] Default theme is similar with Wechat 
- [x] Multiple & mix select support
- [x] Supported media types:
    - [x] Photo
    - [x] GIF
    - [x] Live Photo
    - [x] Video
- [x] Camera
- [ ] Edit image
- [ ] Multiple platform support
    - [x] iOS
    - [x] iPadOS
    - [x] Mac Catalyst ( Technical Preview )
    - [ ] macOS
    - [ ] tvOS

## Requirements

- iOS 10.0+
- Xcode 11.0+
- Swift 5.0+

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

Add this to `Podfile`, and then update dependency:

```ruby
pod 'AnyImagePicker'
```

### [Carthage](https://github.com/Carthage/Carthage)

Add this to `Cartfile`, and then update dependency:

```ogdl
github "AnyImageProject/AnyImagePicker"
```

> Unsupport `--no-use-binaries`

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
