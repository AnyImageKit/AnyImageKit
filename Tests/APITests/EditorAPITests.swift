//
//  EditorAPITests.swift
//  APITests
//
//  Created by 蒋惠 on 2021/11/17.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import XCTest
import AnyImageKit

class EditorAPITests: XCTestCase {

    let testImageEditorControllerDelegate = TestImageEditorControllerDelegate()
    let testImageKitDataTrackDelegate = TestImageKitDataTrackDelegate()
    
    func testOpenPhoto() {
        let editor = ImageEditorController(photo: UIImage(), options: .init(), delegate: testImageEditorControllerDelegate)
        editor.trackDelegate = testImageKitDataTrackDelegate
    }

    func testOpenVideo() {
        let editor = ImageEditorController(video: URL(fileURLWithPath: ""), placeholderImage: nil, options: .init(), delegate: testImageEditorControllerDelegate)
        editor.trackDelegate = testImageKitDataTrackDelegate
    }
    
    class TestImageEditorControllerDelegate: ImageEditorControllerDelegate {
        
        func imageEditorDidCancel(_ editor: ImageEditorController) {
            
        }
        
        func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
            let _ = result.isEdited
            let _ = result.mediaURL
            
            switch result.type {
            case .photo:
                break
            case .video:
                break
            case .photoGIF:
                break
            case .photoLive:
                break
            }
        }
    }
    
    class TestImageKitDataTrackDelegate: ImageKitDataTrackDelegate {
        
        func dataTrack(page: AnyImagePage, state: AnyImagePageState) {
            switch page {
            case .editorPhoto: break
            case .editorInputText: break
            case .editorVideo: break
            default: break
            }
        }
        
        func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey : Any]) {
            switch event {
            case .editorBack: break
            case .editorDone: break
            case .editorCancel: break
            case .editorPhotoBrushUndo: break
            case .editorPhotoMosaicUndo: break
            case .editorPhotoTextSwitch: break
            case .editorPhotoCropRotation: break
            case .editorPhotoCropCancel: break
            case .editorPhotoCropReset: break
            case .editorPhotoCropDone: break
            case .editorPhotoBrush: break
            case .editorPhotoMosaic: break
            case .editorPhotoText: break
            case .editorPhotoCrop: break
            case .editorVideoPlayPause: break
            default: break
            }
        }
    }

    func testPhotoOption() {
        var option = EditorPhotoOptionsInfo()
        option.toolOptions = [.brush, .text, .crop, .mosaic]
        option.brushColors = [.custom(color: .white), .colorWell(color: .white)]
        option.defaultBrushIndex = 0
        option.brushWidth = 0
        option.mosaicOptions = [.default, .custom(icon: nil, mosaic: UIImage())]
        option.mosaicWidth = 0
        option.mosaicLevel = 0
        option.textColors = [.init(color: .white, subColor: .white, shadow: .init(color: .white, alpha: 0, x: 0, y: 0, blur: 0, spread: 0))]
        option.textFont = .systemFont(ofSize: 10)
        option.isTextSelected = true
        option.calculateTextLastLineMask = true
        option.cropOptions = [.free, .custom(w: 1, h: 1)]
        option.rotationDirection = .turnOff
        option.rotationDirection = .turnLeft
        option.rotationDirection = .turnRight
        option.cacheIdentifier = ""
        option.enableDebugLog = true
    }
    
    func testVideoOption() {
        var option = EditorVideoOptionsInfo()
        option.toolOptions = [.clip]
        option.enableDebugLog = true
    }
    
    func testTheme() {
        let theme = EditorTheme()
        theme[color: .primary] = .white
        
        theme[icon: .checkMark] = UIImage()
        theme[icon: .xMark] = UIImage()
        theme[icon: .returnBackButton] = UIImage()
        theme[icon: .photoToolBrush] = UIImage()
        theme[icon: .photoToolText] = UIImage()
        theme[icon: .photoToolCrop] = UIImage()
        theme[icon: .photoToolMosaic] = UIImage()
        theme[icon: .photoToolUndo] = UIImage()
        theme[icon: .photoToolCropTrunLeft] = UIImage()
        theme[icon: .photoToolCropTrunRight] = UIImage()
        theme[icon: .photoToolMosaicDefault] = UIImage()
        theme[icon: .textNormalIcon] = UIImage()
        theme[icon: .trash] = UIImage()
        theme[icon: .videoCropLeft] = UIImage()
        theme[icon: .videoCropRight] = UIImage()
        theme[icon: .videoPauseFill] = UIImage()
        theme[icon: .videoPlayFill] = UIImage()
        theme[icon: .videoToolVideo] = UIImage()
        
        theme[string: .editorBrush] = ""
        theme[string: .editorCrop] = ""
        theme[string: .editorMosaic] = ""
        theme[string: .editorInputText] = ""
        theme[string: .editorFree] = ""
        theme[string: .editorDragHereToRemove] = ""
        theme[string: .editorReleaseToRemove] = ""
        
        theme.configurationLabel(for: .cropOption, configuration: { _ in })
        theme.configurationLabel(for: .trash, configuration: { _ in })
        theme.configurationLabel(for: .videoTimeline, configuration: { _ in })
        
        theme.configurationButton(for: .back, configuration: { _ in })
        theme.configurationButton(for: .cancel, configuration: { _ in })
        theme.configurationButton(for: .done, configuration: { _ in })
        theme.configurationButton(for: .photoOptions(.brush), configuration: { _ in })
        theme.configurationButton(for: .videoOptions(.clip), configuration: { _ in })
        theme.configurationButton(for: .brush(.custom(color: .white)), configuration: { _ in })
        theme.configurationButton(for: .mosaic(.default), configuration: { _ in })
        theme.configurationButton(for: .textColor(.init(color: .white, subColor: .white)), configuration: { _ in })
        theme.configurationButton(for: .undo, configuration: { _ in })
        theme.configurationButton(for: .textSwitch, configuration: { _ in })
        theme.configurationButton(for: .cropRotation, configuration: { _ in })
        theme.configurationButton(for: .cropCancel, configuration: { _ in })
        theme.configurationButton(for: .cropReset, configuration: { _ in })
        theme.configurationButton(for: .cropDone, configuration: { _ in })
        theme.configurationButton(for: .videoPlayPause, configuration: { _ in })
        theme.configurationButton(for: .videoCropLeft, configuration: { _ in })
        theme.configurationButton(for: .videoCropRight, configuration: { _ in })
    }
}
