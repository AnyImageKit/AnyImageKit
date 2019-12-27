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
    func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool)
    func imageEditor(_ editor: ImageEditorController, didFinishEditing video: URL, isEdited: Bool)
}

extension ImageEditorControllerDelegate {
    
    public func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.dismiss(animated: true, completion: nil)
    }
    public func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool) { }
    public func imageEditor(_ editor: ImageEditorController, didFinishEditing video: URL, isEdited: Bool) { }
}

open class ImageEditorController: AnyImageNavigationController {
    
    public private(set) weak var editorDelegate: ImageEditorControllerDelegate?
    
    /// Init image editor
    public convenience init(image: UIImage, options: [AnyImageEditorPhotoOptionsInfoItem] = [], delegate: ImageEditorControllerDelegate) {
        self.init(image: image, options: .init(options), delegate: delegate)
    }
    
    /// Init image editor
    public required init(image: UIImage, options: AnyImageEditorPhotoOptionsInfo = .init(), delegate: ImageEditorControllerDelegate) {
        enableDebugLog = options.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        check(options: options)
        self.editorDelegate = delegate
        let rootViewController = PhotoEditorController(image: image, options: options, delegate: self)
        self.viewControllers = [rootViewController]
    }
    
    /// Init video editor
    public convenience init(video resource: VideoResource, placeholdImage: UIImage?, options: [AnyImageEditorVideoOptionsInfoItem] = [], delegate: ImageEditorControllerDelegate) {
        self.init(video: resource, placeholdImage: placeholdImage, options: .init(options), delegate: delegate)
    }
    
    /// Init video editor
    public required init(video resource: VideoResource, placeholdImage: UIImage?, options: AnyImageEditorVideoOptionsInfo = .init(), delegate: ImageEditorControllerDelegate) {
        enableDebugLog = options.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        self.editorDelegate = delegate
        let rootViewController = VideoEditorController(resource: resource, placeholdImage: placeholdImage, options: options, delegate: self)
        self.viewControllers = [rootViewController]
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private function
extension ImageEditorController {
    
    private func check(options: AnyImageEditorPhotoOptionsInfo) {
        assert(options.cacheIdentifier.firstIndex(of: "/") == nil, "Cache identifier can't contains '/'")
        assert(options.penColors.count <= 7, "Pen colors count can't bigger then 7")
        assert(options.mosaicOptions.count <= 5, "Mosaic count can't bigger then 5")
    }
}

// MARK: - PhotoEditorControllerDelegate
extension ImageEditorController: PhotoEditorControllerDelegate {
    
    func photoEditorDidCancel(_ editor: PhotoEditorController) {
        editorDelegate?.imageEditorDidCancel(self)
    }
    
    func photoEditor(_ editor: PhotoEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        editorDelegate?.imageEditor(self, didFinishEditing: photo, isEdited: isEdited)
    }
}

// MARK: - VideoEditorControllerDelegate
extension ImageEditorController: VideoEditorControllerDelegate {
    
    func videoEditorDidCancel(_ editor: VideoEditorController) {
        editorDelegate?.imageEditorDidCancel(self)
    }
    
    func videoEditor(_ editor: VideoEditorController, didFinishEditing video: URL, isEdited: Bool) {
        
    }
}
