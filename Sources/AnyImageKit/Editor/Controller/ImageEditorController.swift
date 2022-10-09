//
//  ImageEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImageEditorControllerDelegate: AnyObject {
    
    func imageEditorDidCancel(_ editor: ImageEditorController)
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult)
}

extension ImageEditorControllerDelegate {
    
    public func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.dismiss(animated: true, completion: nil)
    }
}

open class ImageEditorController: AnyImageNavigationController {
    
    open weak var editorDelegate: ImageEditorControllerDelegate?
    
    private var containerSize: CGSize = .zero
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    /// Init Photo Editor
    public convenience init(photo resource: EditorPhotoResource, options: EditorPhotoOptionsInfo, delegate: ImageEditorControllerDelegate) {
        self.init()
        self.update(photo: resource, options: options)
        self.editorDelegate = delegate
    }
    
    /// Init Video Editor
    public convenience init(video resource: EditorVideoResource, placeholderImage: UIImage?, options: EditorVideoOptionsInfo, delegate: ImageEditorControllerDelegate) {
        self.init()
        self.update(video: resource, placeholderImage: placeholderImage, options: options)
        self.editorDelegate = delegate
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .fullScreen
    }
    
    deinit {
        removeNotifications()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        addNotification()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newSize = view.frame.size
        if containerSize != .zero, containerSize != newSize {
            view.endEditing(true)
            dismiss(animated: false, completion: nil)
            editorDelegate?.imageEditorDidCancel(self)
        }
        containerSize = newSize
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch UIApplication.shared.statusBarOrientation {
        case .unknown:
            return .portrait
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        }
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
}

extension ImageEditorController {
    
    open func update(photo resource: EditorPhotoResource, options: EditorPhotoOptionsInfo) {
        guard viewControllers.isEmpty || enableForceUpdate else {
            return
        }
        enableDebugLog = options.enableDebugLog
        let checkedOptions = check(resource: resource, options: options)
        let rootViewController = PhotoEditorController(photo: resource, options: checkedOptions, delegate: self)
        rootViewController.trackObserver = self
        viewControllers = [rootViewController]
    }
    
    open func update(video resource: EditorVideoResource, placeholderImage: UIImage?, options: EditorVideoOptionsInfo) {
        enableDebugLog = options.enableDebugLog
        let checkedOptions = check(resource: resource, options: options)
        let rootViewController = VideoEditorController(resource: resource, placeholderImage: placeholderImage, options: checkedOptions, delegate: self)
        rootViewController.trackObserver = self
        viewControllers = [rootViewController]
    }
}

// MARK: - Check
extension ImageEditorController {
    
    private func check(resource: EditorPhotoResource, options: EditorPhotoOptionsInfo) -> EditorPhotoOptionsInfo {
        #if DEBUG
        switch resource {
        case let resource as URL:
            assert(resource.isFileURL, "DO NOT support remote URL yet")
        default:
            break
        }

        assert(options.cacheIdentifier.firstIndex(of: "/") == nil, "Cache identifier can't contains '/'")
        assert(options.mosaicOptions.count <= 5, "Mosaic count can't more then 5")

        if options.rotationDirection != .turnOff {
            for cropOption in options.cropOptions {
                if case let .custom(w, h) = cropOption, !options.cropOptions.contains(.custom(w: h, h: w)) {
                    fatalError("Custom crop option must appear in pairs if you turn on the rotation feature. Please add .custom(\(h), \(w)) to cropOptions")
                }
            }
        }
        #else
        var options = options
        if options.cacheIdentifier.firstIndex(of: "/") != nil {
            options.cacheIdentifier = options.cacheIdentifier.replacingOccurrences(of: "/", with: "-")
        }
        if options.brushColors.count > 7 {
            options.brushColors = Array(options.brushColors.prefix(upTo: 7))
        }
        if options.mosaicOptions.count > 5 {
            options.mosaicOptions = Array(options.mosaicOptions.prefix(upTo: 5))
        }
        if options.cropOptions.isEmpty {
            options.cropOptions = [.free]
        }
        if options.cropOptions.count == 1 {
            if case let .custom(w, h) = options.cropOptions.first, w != h {
                options.rotationDirection = .turnOff
            }
        }
        if options.rotationDirection != .turnOff {
            var addCount = 0
            for (idx, cropOption) in options.cropOptions.enumerated() {
                if case let .custom(w, h) = cropOption, !options.cropOptions.contains(.custom(w: h, h: w)) {
                    options.cropOptions.insert(.custom(w: h, h: w), at: idx + 1 + addCount)
                    addCount += 1
                }
            }
        }
        #endif
        return options
    }
    
    private func check(resource: EditorVideoResource, options: EditorVideoOptionsInfo) -> EditorVideoOptionsInfo {
        switch resource {
        case let resource as URL:
            assert(resource.isFileURL, "DO NOT support remote URL yet")
        default:
            break
        }
        return options
    }
}

// MARK: - Private function
extension ImageEditorController {
    
    private func output(photo: UIImage, fileType: FileType) -> Result<URL, AnyImageError> {
        guard let data = photo.jpegData(compressionQuality: 1.0) else {
            return .failure(.invalidData)
        }
        guard let url = FileHelper.write(photoData: data, fileType: fileType) else {
            return .failure(.fileWriteFailed)
        }
        return .success(url)
    }
}

// MARK: - Notification
extension ImageEditorController {
    
    private func addNotification() {
        beginGeneratingDeviceOrientationNotifications()
    }
    
    private func removeNotifications() {
        endGeneratingDeviceOrientationNotifications()
    }
}

// MARK: - PhotoEditorControllerDelegate
extension ImageEditorController: PhotoEditorControllerDelegate {
    
    func photoEditorDidCancel(_ editor: PhotoEditorController) {
        editorDelegate?.imageEditorDidCancel(self)
    }
    
    func photoEditor(_ editor: PhotoEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        let outputResult = output(photo: photo, fileType: .jpeg)
        switch outputResult {
        case .success(let url):
            let result = EditorResult(mediaURL: url, type: .photo, isEdited: isEdited)
            editorDelegate?.imageEditor(self, didFinishEditing: result)
        case .failure(let error):
            _print(error.localizedDescription)
        }
    }
}

// MARK: - VideoEditorControllerDelegate
extension ImageEditorController: VideoEditorControllerDelegate {
    
    func videoEditorDidCancel(_ editor: VideoEditorController) {
        editorDelegate?.imageEditorDidCancel(self)
    }
    
    func videoEditor(_ editor: VideoEditorController, didFinishEditing video: URL, isEdited: Bool) {
        let result = EditorResult(mediaURL: video, type: .video, isEdited: isEdited)
        editorDelegate?.imageEditor(self, didFinishEditing: result)
    }
}
