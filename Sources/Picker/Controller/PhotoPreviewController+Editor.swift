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
                let options = _PhotoFetchOptions(sizeMode: .preview(manager.config.largePhotoMaxWidth))
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
        } else if data.asset.phAsset.mediaType == .video {
            manager.cancelFetch(for: data.asset.phAsset.localIdentifier)
            var config = manager.editorConfig.videoConfig
            config.enableDebugLog = manager.config.enableDebugLog
            let image = data.asset._images[.initial] ?? data.thumbnail
            let controller = ImageEditorController(video: data.asset.phAsset, placeholdImage: image, config: config, delegate: self)
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: false, completion: nil)
        }
    }
    
    @objc func previewCellDidDownloadResource(_ notification: Notification) {
        guard let asset = notification.object as? Asset else { return }
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        guard asset == data.asset else { return }
        autoSetEditorButtonHidden()
    }
}

// MARK: - Internal function
extension PhotoPreviewController {
    
    internal func autoSetEditorButtonHidden() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return } // Editor not support iPad yet
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        guard let cell = (collectionView.visibleCells.compactMap{ $0 as? PreviewCell }.filter{ $0.asset == data.asset }.first), cell.isDownloaded else { return }
        
        if data.asset.phAsset.mediaType == .image && manager.editorConfig.options.contains(.photo) {
            toolBar.leftButton.isHidden = false
        } else if data.asset.phAsset.mediaType == .video && manager.editorConfig.options.contains(.video) {
            toolBar.leftButton.isHidden = false
        } else {
            toolBar.leftButton.isHidden = true
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

// MARK: - ImageEditorControllerDelegate
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
