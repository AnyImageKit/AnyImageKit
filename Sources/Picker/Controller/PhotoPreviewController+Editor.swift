//
//  PhotoPreviewController+Editor.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/14.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

#if ANYIMAGEKIT_ENABLE_EDITOR

// MARK: - Target
extension PhotoPreviewController {
    /// ToolBar - Edit - not finish
    @objc func editButtonTapped(_ sender: UIButton) {
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        if data.asset.phAsset.mediaType == .image {
            showWaitHUD()
            let options = PhotoFetchOptions(sizeMode: .preview)
            PickerManager.shared.requestPhoto(for: data.asset.phAsset, options: options) { [weak self] result in
                guard let self = self else { return }
                hideHUD()
                switch result {
                case .success(let response):
                    if !response.isDegraded {
                        let config = PickerManager.shared.config.editorPhotoConfig
                        let controller = ImageEditorController(image: response.image, config: config, delegate: self)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: false, completion: nil)
                    }
                case .failure(let error):
                    _print(error)
                }
            }
        }
    }
}

extension PhotoPreviewController: ImageEditorControllerDelegate {
    
    func imageEditorDidFinish(_ controller: ImageEditorController, photo: UIImage, isEdited: Bool) {
        
    }
}

#endif
