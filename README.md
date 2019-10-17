# AnyImagePicker

`AnyImagePicker` is an image picker which support multiple photos, GIF or video. [中文说明](./README_CN.md)

## Features

- [x] Light mode, Dard mode or Auto mode support
- [x] Default theme is similar with Wechat 
- [x] Multiple/mix select
- [ ] Support Media Type:
    - [x] Photo
    - [x] GIF
    - [ ] LivePhoto
    - [x] Video
- [ ] Camera
- [ ] Edit Image
- [ ] Multiple platform support
    - [x] iOS
    - [ ] iPadOS
    - [ ] tvOS
    - [ ] Catalyst
    - [ ] macOS

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

## License

AnyImagePicker is released under the MIT license. See [LICENSE](./LICENSE) for details.