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
    
    /// Init image editor
    public convenience init(photo resource: EditorPhotoResource, options: EditorPhotoOptionsInfo = .empty, delegate: ImageEditorControllerDelegate) {
        self.init(photo: resource, options: .init(options), delegate: delegate)
    }
    
    /// Init image editor
    public required init(photo resource: EditorPhotoResource, options: EditorPhotoParsedOptionsInfo, delegate: ImageEditorControllerDelegate) {
        enableDebugLog = options.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        let checkedOptions = check(resource: resource, options: options)
        self.editorDelegate = delegate
        let rootViewController = PhotoEditorController(photo: resource, options: checkedOptions, delegate: self)
        self.viewControllers = [rootViewController]
    }
    
    /// Init video editor
    public convenience init(video resource: EditorVideoResource, placeholdImage: UIImage?, options: EditorVideoOptionsInfo = .empty, delegate: ImageEditorControllerDelegate) {
        self.init(video: resource, placeholdImage: placeholdImage, options: .init(options), delegate: delegate)
    }
    
    /// Init video editor
    public required init(video resource: EditorVideoResource, placeholdImage: UIImage?, options: EditorVideoParsedOptionsInfo, delegate: ImageEditorControllerDelegate) {
        enableDebugLog = options.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        let checkedOptions = check(resource: resource, options: options)
        self.editorDelegate = delegate
        let rootViewController = VideoEditorController(resource: resource, placeholdImage: placeholdImage, options: checkedOptions, delegate: self)
        self.viewControllers = [rootViewController]
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Private function
extension ImageEditorController {
    
    private func check(resource: EditorPhotoResource, options: EditorPhotoParsedOptionsInfo) -> EditorPhotoParsedOptionsInfo {
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
    
    private func check(resource: EditorVideoResource, options: EditorVideoParsedOptionsInfo) -> EditorVideoParsedOptionsInfo {
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
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let tmpPath = NSTemporaryDirectory()
        let filePath = tmpPath.appending("PHOTO-SAVED-\(timestamp)"+fileType.fileExtension)
        FileHelper.createDirectory(at: tmpPath)
        let url = URL(fileURLWithPath: filePath)
        do {
            try data.write(to: url)
        } catch {
            _print(error.localizedDescription)
            return .failure(.fileWriteFailed)
        }
        return .success(url)
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
            editorDelegate?.imageEditor(self, didFinishEditing: url, type: .photo, isEdited: isEditing)
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
