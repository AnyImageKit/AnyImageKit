//
//  PhotoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImageEditorControllerDelegate: class {
    
    func imageEditorDidCancel(_ editor: ImageEditorController)
    func imageEditor(_ editor: ImageEditorController, didFinishEditing mediaURL: URL, type: MediaType, isEdited: Bool)
}

extension ImageEditorControllerDelegate {
    
    public func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.dismiss(animated: true, completion: nil)
    }
}

open class ImageEditorController: AnyImageNavigationController {
    
    public private(set) weak var editorDelegate: ImageEditorControllerDelegate?
    
    /// Init Photo Editor
    public required init(photo resource: EditorPhotoResource, options: EditorPhotoOptionsInfo, delegate: ImageEditorControllerDelegate) {
        enableDebugLog = options.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        let checkedOptions = check(resource: resource, options: options)
        self.editorDelegate = delegate
        let rootViewController = PhotoEditorController(photo: resource, options: checkedOptions, delegate: self)
        self.viewControllers = [rootViewController]
    }
    
    /// Init Video Editor
    public required init(video resource: EditorVideoResource, placeholderImage: UIImage?, options: EditorVideoOptionsInfo, delegate: ImageEditorControllerDelegate) {
        enableDebugLog = options.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        let checkedOptions = check(resource: resource, options: options)
        self.editorDelegate = delegate
        let rootViewController = VideoEditorController(resource: resource, placeholderImage: placeholderImage, options: checkedOptions, delegate: self)
        self.viewControllers = [rootViewController]
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        addNotification()
    }
    
    deinit {
        removeNotifications()
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Private function
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
        assert(options.penColors.count <= 7, "Pen colors count can't more then 7")
        assert(options.mosaicOptions.count <= 5, "Mosaic count can't more then 5")
        #else
        var options = options
        if options.cacheIdentifier.firstIndex(of: "/") != nil {
            options.cacheIdentifier = options.cacheIdentifier.replacingOccurrences(of: "/", with: "-")
        }
        if options.penColors.count > 7 {
            options.penColors = Array(options.penColors.prefix(upTo: 7))
        }
        if options.mosaicOptions.count > 5 {
            options.mosaicOptions = Array(options.mosaicOptions.prefix(upTo: 5))
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
    
    private func output(photo: UIImage, fileType: FileType) -> Result<URL, AnyImageError> {
        guard let data = photo.jpegData(compressionQuality: 1.0) else {
            return .failure(.invalidData)
        }
        guard let url = FileHelper.write(photoData: data, utType: fileType.utType) else {
            return .failure(.fileWriteFailed)
        }
        return .success(url)
    }
}

// MARK: - Notification
extension ImageEditorController {
    
    private func addNotification() {
        beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChangeNotification(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func removeNotifications() {
        endGeneratingDeviceOrientationNotifications()
    }
    
    @objc private func orientationDidChangeNotification(_ sender: Notification) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.endEditing(true)
            presentingViewController?.dismiss(animated: false, completion: nil)
            editorDelegate?.imageEditorDidCancel(self)
        }
    }
}

// MARK: - PhotoEditorControllerDelegate
extension ImageEditorController: PhotoEditorControllerDelegate {
    
    func photoEditorDidCancel(_ editor: PhotoEditorController) {
        editorDelegate?.imageEditorDidCancel(self)
    }
    
    func photoEditor(_ editor: PhotoEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        let result = output(photo: photo, fileType: .jpeg)
        switch result {
        case .success(let url):
            editorDelegate?.imageEditor(self, didFinishEditing: url, type: .photo, isEdited: isEdited)
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
        editorDelegate?.imageEditor(self, didFinishEditing: video, type: .video, isEdited: isEditing)
    }
}
