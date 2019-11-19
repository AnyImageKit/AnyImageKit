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
}

open class ImageEditorController: UINavigationController {
    
    open weak var editorDelegate: ImageEditorControllerDelegate?
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    required public init(image: UIImage, config: PhotoConfig = PhotoConfig(), delegate: ImageEditorControllerDelegate) {
        EditorManager.shared.image = image
        EditorManager.shared.photoConfig = config
        let rootViewController = PhotoEditorController()
        super.init(rootViewController: rootViewController)
        rootViewController.delegate = self
        self.editorDelegate = delegate
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public static function
extension ImageEditorController {
    
    public static func deleteCache(id: String) {
        EditorImageCache.delete(id: id)
    }
    
    public static func deleteAllCache() {
        EditorImageCache.deleteAll()
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
