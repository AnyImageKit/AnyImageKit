//
//  PickerAPITests.swift
//  APITests
//
//  Created by 蒋惠 on 2021/11/17.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import XCTest
import ObjectiveC
@testable import AnyImageKit

class PickerAPITests: XCTestCase {

    let testImagePickerControllerDelegate = TestImagePickerControllerDelegate()
    let testImageKitDataTrackDelegate = TestImageKitDataTrackDelegate()
    
    func testOpen() {
        let picker = ImagePickerController(options: .init(), delegate: testImagePickerControllerDelegate)
        picker.trackDelegate = testImageKitDataTrackDelegate
    }

    class TestImagePickerControllerDelegate: ImagePickerControllerDelegate {
        
        func imagePickerDidCancel(_ picker: ImagePickerController) {
            
        }
        
        func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
            let _ = result.assets
            let _ = result.useOriginalImage
        }
    }
    
    class TestImageKitDataTrackDelegate: ImageKitDataTrackDelegate {
        
        func dataTrack(page: AnyImagePage, state: AnyImagePageState) {
            switch page {
            case .pickerAlbum: break
            case .pickerAsset: break
            case .pickerPreview: break
            default: break
            }
        }
        
        func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey : Any]) {
            switch event {
            case .pickerCancel: break
            case .pickerDone: break
            case .pickerSelect: break
            case .pickerSwitchAlbum: break
            case .pickerPreview: break
            case .pickerEdit: break
            case .pickerOriginalImage: break
            case .pickerBackInPreview: break
            case .pickerLimitedLibrary: break
            case .pickerTakePhoto: break
            case .pickerTakeVideo: break
            default: break
            }
        }
    }
    
    func testOption() {
        var option = PickerOptionsInfo()
        option.selectLimit = 0
        option.columnNumber = 0
        option.autoCalculateColumnNumber = true
        option.photoMaxWidth = 0
        option.largePhotoMaxWidth = 0
        option.allowUseOriginalImage = true
        option.albumOptions = [.smart, .userCreated]
        option.selectOptions = [.photo, .video, .photoGIF, .photoLive]
        option.selectionTapAction = .preview
        option.selectionTapAction = .openEditor
        option.selectionTapAction = .quickPick
        option.orderByDate = .asc
        option.orderByDate = .desc
        option.preselectAssets = []
        option.disableRules = []
        option.enableDebugLog = true
        option.saveEditedAsset = true
        option.editorOptions = [.photo]
        option.useSameEditorOptionsInCapture = true
    }
    
    func testTheme() {
        let theme = PickerTheme(style: .auto)
        
        theme[color: .primary] = .white
        theme[color: .text] = .white
        theme[color: .subText] = .white
        theme[color: .toolBar] = .white
        theme[color: .background] = .white
        theme[color: .selectedCell] = .white
        theme[color: .separatorLine] = .white
        
        theme[icon: .albumArrow] = UIImage()
        theme[icon: .arrowRight] = UIImage()
        theme[icon: .camera] = UIImage()
        theme[icon: .checkOff] = UIImage()
        theme[icon: .checkOn] = UIImage()
        theme[icon: .iCloud] = UIImage()
        theme[icon: .livePhoto] = UIImage()
        theme[icon: .photoEdited] = UIImage()
        theme[icon: .pickerCircle] = UIImage()
        theme[icon: .returnButton] = UIImage()
        theme[icon: .returnButtonLiquidGlass] = UIImage()
        theme[icon: .video] = UIImage()
        theme[icon: .videoPlay] = UIImage()
        theme[icon: .warning] = UIImage()
        
        theme[string: .pickerOriginalImage] = ""
        theme[string: .pickerSelectPhoto] = ""
        theme[string: .pickerUnselectPhoto] = ""
        theme[string: .pickerTakePhoto] = ""
        theme[string: .pickerSelectMaximumOfPhotos] = ""
        theme[string: .pickerSelectMaximumOfVideos] = ""
        theme[string: .pickerSelectMaximumOfPhotosOrVideos] = ""
        theme[string: .pickerDownloadingFromiCloud] = ""
        theme[string: .pickerFetchFailedPleaseRetry] = ""
        theme[string: .pickerA11ySwitchAlbumTips] = ""
        theme[string: .pickerLimitedPhotosPermissionTips] = ""
        
        theme.configurationLabel(for: .permissionLimitedTips, configuration: { _ in })
        theme.configurationLabel(for: .permissionDeniedTips, configuration: { _ in })
        theme.configurationLabel(for: .albumTitle, configuration: { _ in })
        theme.configurationLabel(for: .albumCellTitle, configuration: { _ in })
        theme.configurationLabel(for: .albumCellSubTitle, configuration: { _ in })
        theme.configurationLabel(for: .assetCellVideoDuration, configuration: { _ in })
        theme.configurationLabel(for: .assetCellGIFMark, configuration: { _ in })
        theme.configurationLabel(for: .selectedNumber, configuration: { _ in })
        theme.configurationLabel(for: .selectedNumberInPreview, configuration: { _ in })
        theme.configurationLabel(for: .livePhotoMark, configuration: { _ in })
        theme.configurationLabel(for: .loadingFromiCloudTips, configuration: { _ in })
        theme.configurationLabel(for: .loadingFromiCloudProgress, configuration: { _ in })
        
        theme.configurationButton(for: .preview, configuration: { _ in })
        theme.configurationButton(for: .edit, configuration: { _ in })
        theme.configurationButton(for: .originalImage, configuration: { _ in })
        theme.configurationButton(for: .done, configuration: { _ in })
        theme.configurationButton(for: .backInPreview, configuration: { _ in })
        theme.configurationButton(for: .goSettings, configuration: { _ in })
        
        theme.configurationBarButton(for: .close, configuration: { _ in })
        theme.configurationBarButton(for: .done, configuration: { _ in })
        theme.configurationBarButton(for: .preview, configuration: { _ in })
        theme.configurationBarButton(for: .more, configuration: { _ in })
        
        theme.configurationGlassButton(for: .album, configuration: { _ in })
        theme.configurationGlassButton(for: .limitedPermission, configuration: { _ in })
        theme.configurationGlassButton(for: .edit, configuration: { _ in })
        theme.configurationGlassButton(for: .originalImage, configuration: { _ in })
        theme.configurationGlassButton(for: .done, configuration: { _ in })
        theme.configurationGlassButton(for: .back, configuration: { _ in })
        theme.configurationGlassButton(for: .select, configuration: { _ in })
    }
    
    func testGlassButtonConfigurationIsLastWriter() {
        guard #available(iOS 26.0, *) else { return }
        
        let theme = PickerTheme(style: .light)
        theme[string: .pickerA11ySwitchAlbumTips] = "Album %@"
        theme.configurationGlassButton(for: .album) { button in
            button.menu = nil
            button.showsMenuAsPrimaryAction = false
            button.accessibilityLabel = "custom-album"
            var config = button.configuration ?? .clearGlass()
            config.title = "pinned-album"
            button.configuration = config
        }
        theme.configurationGlassButton(for: .limitedPermission) { button in
            button.accessibilityLabel = "custom-limited"
            var config = button.configuration ?? .glass()
            config.title = "pinned-limited"
            button.configuration = config
        }
        let checkOff = UIImage(systemName: "circle")
        let checkOn = UIImage(systemName: "checkmark.circle")
        theme[icon: .checkOff] = checkOff
        theme[icon: .checkOn] = checkOn
        theme.configurationGlassButton(for: .originalImage) { button in
            var config = button.configuration ?? .glass()
            config.image = UIImage(systemName: "xmark")
            button.configuration = config
        }
        theme.configurationGlassButton(for: .select) { button in
            button.accessibilityIdentifier = "select-configured"
            button.accessibilityLabel = "custom-select"
        }
        var options = PickerOptionsInfo()
        options.theme = theme
        
        let view = AssetLGView(frame: .zero)
        view.update(options: options)
        let albumMenu = UIMenu(title: "albums", children: [])
        view.albumButton.menu = albumMenu
        view.albumButton.showsMenuAsPrimaryAction = true
        view.setAlbumTitle("Trip")
        XCTAssertEqual(view.albumButton.configuration?.title, "Trip")
        XCTAssertEqual(view.albumButton.accessibilityLabel, "Album Trip")
        XCTAssertTrue(view.albumButton.showsMenuAsPrimaryAction)
        XCTAssertEqual(view.albumButton.menu?.title, "albums")
        XCTAssertEqual(view.limitedButton.accessibilityLabel, "custom-limited")
        
        view.collapseLimitedButtonTitle()
        XCTAssertEqual(view.limitedButton.accessibilityLabel, "custom-limited")
        XCTAssertNil(view.limitedButton.configuration?.title)
        
        let selectButton = NumberCircleLGButton(type: .system)
        selectButton.configuration = .glass()
        selectButton.update(options: options)
        selectButton.setNum(2, isSelected: true, animated: false)
        XCTAssertEqual(selectButton.accessibilityIdentifier, "select-configured")
        XCTAssertEqual(selectButton.accessibilityLabel, "custom-select")
        
        let toolBar = PreviewLGToolBar(frame: .zero)
        toolBar.update(options: options)
        XCTAssertEqual(toolBar.editButton.configuration?.titleTextAttributesTransformer?(AttributeContainer()).font, .systemFont(ofSize: 18))
        XCTAssertEqual(toolBar.originalButton.configuration?.titleTextAttributesTransformer?(AttributeContainer()).font, .systemFont(ofSize: 16))
        XCTAssertTrue(toolBar.originalButton.configuration?.image === checkOff)
        toolBar.setOriginalSelected(true)
        XCTAssertTrue(toolBar.originalButton.configuration?.image === checkOn)
        XCTAssertEqual(toolBar.doneButton.configuration?.titleTextAttributesTransformer?(AttributeContainer()).font, .systemFont(ofSize: 18, weight: .bold))
    }
    
    func testGlassButtonConfigurationIsSkippedInCompatibilityMode() {
        guard #available(iOS 26.0, *) else { return }
        
        BundleInfoDictionaryStub.compatibility = true
        BundleInfoDictionaryStub.swizzle()
        defer {
            BundleInfoDictionaryStub.swizzle()
            BundleInfoDictionaryStub.compatibility = nil
        }
        
        let theme = PickerTheme(style: .light)
        theme.configurationGlassButton(for: .album) { button in
            button.accessibilityIdentifier = "album-ran"
        }
        theme.configurationGlassButton(for: .limitedPermission) { button in
            button.accessibilityIdentifier = "limited-ran"
        }
        var options = PickerOptionsInfo()
        options.theme = theme
        
        let view = AssetLGView(frame: .zero)
        view.update(options: options)
        view.setAlbumTitle("Trip")
        view.collapseLimitedButtonTitle()
        
        XCTAssertNil(view.albumButton.accessibilityIdentifier)
        XCTAssertNil(view.limitedButton.accessibilityIdentifier)
        XCTAssertEqual(view.albumButton.title(for: .normal), "Trip")
    }
}

private enum BundleInfoDictionaryStub {
    static var compatibility: Bool?
    private static var didSwizzle = false
    
    static func swizzle() {
        let original = class_getInstanceMethod(Bundle.self, #selector(Bundle.object(forInfoDictionaryKey:)))
        let stub = class_getInstanceMethod(Bundle.self, #selector(Bundle.aik_test_object(forInfoDictionaryKey:)))
        guard let original, let stub else { return }
        if !didSwizzle {
            method_exchangeImplementations(original, stub)
            didSwizzle = true
        } else {
            method_exchangeImplementations(original, stub)
            didSwizzle = false
        }
    }
}

private extension Bundle {
    @objc func aik_test_object(forInfoDictionaryKey key: String) -> Any? {
        if key == "UIDesignRequiresCompatibility", let compatibility = BundleInfoDictionaryStub.compatibility {
            return compatibility
        }
        return aik_test_object(forInfoDictionaryKey: key)
    }
}
