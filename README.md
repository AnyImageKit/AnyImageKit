![AnyImageKit](https://github.com/AnyImageProject/AnyImageProject.github.io/raw/master/Resources/TitleMap@2x.png)

[![GitHub Actions](https://github.com/AnyImageKit/AnyImageKit/workflows/build/badge.svg?branch=master)](https://github.com/AnyImageKit/AnyImageKit/actions?query=workflow%3Abuild)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AnyImageKit.svg)](https://cocoapods.org/pods/AnyImageKit)
[![Platform](https://img.shields.io/cocoapods/p/AnyImageKit.svg?style=flat)](./)
[![License](https://img.shields.io/cocoapods/l/AnyImageKit.svg?style=flat)](https://raw.githubusercontent.com/AnyImageKit/AnyImageKit/master/LICENSE)

`AnyImageKit` is a toolbox for picking, editing or capturing photos/videos, written in Swift. 

> [中文说明](./Documentation/README_CN.md)

## Features

- [x] Modular design
    - [x] Picker
    - [ ] Browser
    - [x] Editor
    - [x] Capture
- [x] Light mode, dark mode or auto mode support
- [x] Default theme is similar with Wechat 
- [x] Multiple & mix select support
- [x] Supported media types:
    - [x] Photo
    - [x] GIF
    - [x] Live Photo
    - [x] Video
- [x] Camera
    - [x] Photo
    - [x] Video
    - [ ] Live Photo
    - [ ] GIF
    - [ ] Filter Support
- [ ] Edit image ( Technical Preview )
    - [x] Drawing
    - [ ] Emoji
    - [x] Input text
    - [x] Cropping
    - [x] Mosaic
    - [x] Rotate
    - [ ] Filter Support
- [x] Multiple platform support
    - [x] iOS
    - [x] iPadOS
    - [x] Mac Catalyst ( Technical Preview, Not support in editor.)
    - [ ] macOS
    - [ ] tvOS
- [x] Internationalization support
    - [x] English (en)
    - [x] Chinese, Simplified (zh-Hans)
    - [x] Turkish (tr)
    - [x] Portuguese(Brazil) (pt-BR)
    - [ ] and more... (Pull requests welcome)

## Requirements

- iOS 12.0+
- Xcode 14.1+
- Swift 5.7+

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

⚠️ Needs Xcode 12.0+ to support resources and localization files

```swift
dependencies: [
    .package(url: "https://github.com/AnyImageKit/AnyImageKit.git", .upToNextMajor(from: "0.15.1"))
]
```

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

Add this to `Podfile`, and then update dependency:

```ruby
pod 'AnyImageKit'
```

## Usage

### Prepare

Add these keys to your Info.plist when needed:

| Key | Module | Info |
| ----- | ----  | ---- |
| NSPhotoLibraryUsageDescription | Picker |  |
| NSPhotoLibraryAddUsageDescription | Picker |  |
| PHPhotoLibraryPreventAutomaticLimitedAccessAlert | Picker | Set `YES` to prevent automatic limited access alert in iOS 14+ (Picker has been adapted with Limited features that can be triggered by the user to enhance the user experience) |
| NSCameraUsageDescription | Capture |  |
| NSMicrophoneUsageDescription | Capture |  |

### Quick Start

```swift
import AnyImageKit

class ViewController: UIViewController {

    @IBAction private func openPicker(_ sender: UIButton) {
        var options = PickerOptionsInfo()
        /*
          Your code, handle custom options
        */
        let controller = ImagePickerController(options: options, delegate: self)
        present(controller, animated: true, completion: nil)
    }
}

extension ViewController: ImagePickerControllerDelegate {

    func imagePickerDidCancel(_ picker: ImagePickerController) {
        /*
          Your code, handle user cancel
        */
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
        let images = result.assets.map { $0.image }
        /*
          Your code, handle selected assets
        */
        picker.dismiss(animated: true, completion: nil)
    }
}
```

## Release Notes

| Version | Release Date | Xcode | Swift | iOS |
| ---- | ----  | ---- | ---- | ---- |
| [v0.15.1](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0151) | 2022-12-15 | 14.1 | 5.7 | 12.0+ |
| [v0.15.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0150) | 2022-11-11 | 14.1 | 5.7 | 12.0+ |
| [v0.14.6](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0146) | 2022-07-06 | 13.4.1 | 5.6 | 13.0+ |
| [v0.14.5](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0145) | 2022-07-05 | 13.4.1 | 5.6 | 13.0+ |
| [v0.14.4](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0144) | 2022-04-06 | 13.3 | 5.5 | 12.0+ |
| [v0.14.3](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0143) | 2021-12-28 | 13.2 | 5.5 | 12.0+ |
| [v0.14.2](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0142) | 2021-12-16 | 13.2 | 5.5 | 12.0+ |
| [v0.14.1](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0141) | 2021-11-23 | 13.1 | 5.5 | 12.0+ |
| [v0.14.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0140) | 2021-11-22 | 13.1 | 5.5 | 12.0+ |
| [v0.13.5](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0135) | 2021-10-15 | 13.0 | 5.5 | 12.0+ |
| [v0.13.4](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0134) | 2021-09-23 | 13.0 | 5.5 | 12.0+ |
| [v0.13.3](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0133) | 2021-08-09 | 12.5 | 5.4 | 10.0+ |
| [v0.13.2](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0132) | 2021-06-30 | 12.5 | 5.4 | 10.0+ |
| [v0.13.1](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0131) | 2021-06-01 | 12.5 | 5.4 | 10.0+ |
| [v0.13.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0130) | 2021-02-08 | 12.4 | 5.3 | 10.0+ |
| [v0.12.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0120) | 2020-12-30 | 12.2 | 5.3 | 10.0+ |
| [v0.11.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0110) | 2020-12-18 | 12.2 | 5.3 | 10.0+ |
| [v0.10.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#0100) | 2020-11-03 | 12.1 | 5.3 | 10.0+ |
| [v0.9.0](https://github.com/AnyImageKit/AnyImageKit/blob/master/Documentation/RELEASE_NOTE.md#090) | 2020-10-09 | 12.0 | 5.3 | 10.0+ |

## License

AnyImageKit is released under the MIT license. See [LICENSE](./LICENSE) for details.
