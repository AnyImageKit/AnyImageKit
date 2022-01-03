//
//  PickerAPITests.swift
//  APITests
//
//  Created by 蒋惠 on 2021/11/17.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import XCTest
import AnyImageKit

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
    }
}
