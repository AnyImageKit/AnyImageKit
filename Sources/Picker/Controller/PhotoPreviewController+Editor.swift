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
    /// ToolBar - Edit
    @objc func editButtonTapped(_ sender: UIButton) {
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        if data.asset.phAsset.mediaType == .image {
            if let image = data.asset._images[.initial] {
                showEditor(image, identifier: data.asset.phAsset.localIdentifier)
            } else {
                showWaitHUD()
                let options = PhotoFetchOptions(sizeMode: .preview(manager.config.largePhotoMaxWidth))
                manager.requestPhoto(for: data.asset.phAsset, options: options) { [weak self] result in
                    guard let self = self else { return }
                    hideHUD()
                    switch result {
                    case .success(let response):
                        if !response.isDegraded {
                            self.showEditor(response.image, identifier: data.asset.phAsset.localIdentifier)
                        }
                    case .failure(let error):
                        _print(error)
                    }
                }
            }
        }
    }
}

// MARK: - Private function
extension PhotoPreviewController {
    
    private func showEditor(_ image: UIImage, identifier: String) {
        var config = manager.editorConfig.photoConfig
        config.enableDebugLog = manager.config.enableDebugLog
        config.cacheIdentifier = identifier.replacingOccurrences(of: "/", with: "-")
        let controller = ImageEditorController(image: image, config: config, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false, completion: nil)
    }
}

extension PhotoPreviewController: ImageEditorControllerDelegate {
    
    func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.dismiss(animated: false, completion: nil)
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        defer { editor.dismiss(animated: false, completion: nil) }
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? PhotoPreviewCell else { return }
        data.asset._images[.edited] = isEdited ? photo : nil
        cell.setImage(photo)
        
        // 选择当前照片
        if !manager.isUpToLimit {
            if !data.asset.isSelected {
                selectButtonTapped(navigationBar.selectButton)
            }
        }
    }
}

#endif
