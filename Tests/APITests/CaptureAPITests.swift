//
//  CaptureAPITests.swift
//  APITests
//
//  Created by 蒋惠 on 2021/11/17.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import XCTest
import AnyImageKit

class CaptureAPITests: XCTestCase {

    let testImageCaptureControllerDelegate = TestImageCaptureControllerDelegate()
    let testImageKitDataTrackDelegate = TestImageKitDataTrackDelegate()
    
    func testOpen() {
        let capture = ImageCaptureController(options: .init(), delegate: testImageCaptureControllerDelegate)
        capture.trackDelegate = testImageKitDataTrackDelegate
    }

    class TestImageCaptureControllerDelegate: ImageCaptureControllerDelegate {
        
        func imageCaptureDidCancel(_ capture: ImageCaptureController) {
            
        }
        
        func imageCapture(_ capture: ImageCaptureController, didFinishCapturing result: CaptureResult) {
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
            case .capture: break
            default: break
            }
        }
        
        func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey : Any]) {
            switch event {
            case .capturePhoto: break
            case .captureVideo: break
            case .captureCancel: break
            case .captureSwitchCamera: break
            default: break
            }
        }
    }
    
    func testOption() {
        var option = CaptureOptionsInfo()
        option.mediaOptions = [.photo, .video]
        option.photoAspectRatio = .ratio1x1
        option.photoAspectRatio = .ratio4x3
        option.photoAspectRatio = .ratio16x9
        option.preferredPositions = [.back, .front]
        option.flashMode = .off
        option.flashMode = .on
        option.flashMode = .auto
        option.videoMaximumDuration = 0
        option.preferredPresets = [.hd1280x720_30, .hd1280x720_60, .hd1920x1080_30, .hd1920x1080_60, .hd3840x2160_30, .hd3840x2160_60]
        option.enableDebugLog = true
    }
    
    func testTheme() {
        let theme = CaptureTheme()
        
        theme[color: .primary] = .white
        theme[color: .focus] = .white
        
        theme[icon: .cameraSwitch] = UIImage()
        theme[icon: .captureSunlight] = UIImage()
        
        theme[string: .captureSwitchToFrontCamera] = ""
        theme[string: .captureSwitchToBackCamera] = ""
        theme[string: .captureTapForPhoto] = ""
        theme[string: .captureHoldForVideo] = ""
        theme[string: .captureHoldForVideoTapForPhoto] = ""
        
        theme.configurationLabel(for: .tips, configuration: { _ in })
        
        theme.configurationButton(for: .cancel, configuration: { _ in })
        theme.configurationButton(for: .switchCamera, configuration: { _ in })
    }
}
