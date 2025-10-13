//
//  PhotoPreviewController+Editor.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/14.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

#if ANYIMAGEKIT_ENABLE_EDITOR

// MARK: - Target
extension PhotoPreviewController {
    
    /// ToolBar - Edit
    @objc func editButtonTapped(_ sender: UIButton) {
        let asset = assets[currentIndex]
        trackObserver?.track(event: .pickerEdit, userInfo: [:])
        if asset.mediaType == .photo {
            if let image = asset._images[.initial] {
                showEditor(image, identifier: asset.identifier)
            } else {
                view.hud.show()
                let options = _PhotoFetchOptions(sizeMode: .preview(manager.options.largePhotoMaxWidth))
                manager.requestPhoto(for: asset.phAsset, options: options) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        if !response.isDegraded {
                            self.view.hud.hide()
                            self.showEditor(response.image, identifier: asset.identifier)
                        }
                    case .failure(let error):
                        self.view.hud.hide()
                        _print(error)
                    }
                }
            }
        } else if asset.phAsset.mediaType == .video {
            manager.cancelFetch(for: asset.identifier)
            var videoOptions = manager.options.editorVideoOptions
            videoOptions.enableDebugLog = manager.options.enableDebugLog
            let image = asset._images[.initial]
            let controller = ImageEditorController(video: asset.phAsset, placeholderImage: image, options: videoOptions, delegate: self)
            present(controller, animated: false, completion: nil)
        }
    }
    
    @objc func previewCellDidDownloadResource(_ notification: Notification) {
        // TODO: 改成点击编辑，如果没下载完成，重新开始一个新的下载任务，完成再进去
//        guard let asset = notification.object as? Asset else { return }
//        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
//        guard asset == data.asset else { return }
//        autoSetEditorButtonHidden()
    }
}

// MARK: - Internal function
extension PhotoPreviewController {
    
    internal func autoSetEditorButtonHidden() {
        toolBar.leftButton.isHidden = true
        let asset = assets[currentIndex]
        // TODO: 这里要判断是否下载完成
        
        if asset.mediaType == .photo && manager.options.editorOptions.contains(.photo) {
            toolBar.leftButton.isHidden = false
        } else if asset.phAsset.mediaType == .video && manager.options.editorOptions.contains(.video) {
            toolBar.leftButton.isHidden = false
        }
    }
}

// MARK: - Private function
extension PhotoPreviewController {
    
    private func showEditor(_ image: UIImage, identifier: String) {
        var options = manager.options.editorPhotoOptions
        options.enableDebugLog = manager.options.enableDebugLog
        options.cacheIdentifier = identifier.replacingOccurrences(of: "/", with: "-")
        let controller = ImageEditorController(photo: image, options: options, delegate: self)
        present(controller, animated: false, completion: nil)
    }
}

// MARK: - ImageEditorControllerDelegate
extension PhotoPreviewController: ImageEditorControllerDelegate {
    
    func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.dismiss(animated: false, completion: nil)
        // TODO: 这里似乎不用改
//        let indexPath = IndexPath(item: currentIndex, section: 0)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//        }
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
        defer { editor.dismiss(animated: false, completion: nil) }
        guard result.type == .photo else { return }
        guard let photoData = try? Data(contentsOf: result.mediaURL) else { return }
        guard let photo = UIImage(data: photoData) else { return }
        let asset = assets[currentIndex]
        // TODO: 重新设置数据源
//        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? PhotoPreviewCell else { return }
//        data.asset._images[.edited] = result.isEdited ? photo : nil
//        cell.setImage(photo)
        
        // 选择当前照片
        if !manager.isUpToLimit {
            if !asset.isSelected {
                selectButtonTapped(navigationBar.selectButton)
            }
        }
        delegate?.previewController(self, didSelected: currentIndex)
    }
}

#endif
