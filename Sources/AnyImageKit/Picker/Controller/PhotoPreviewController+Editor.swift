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
    @objc func editButtonTapped() {
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
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
        defer { editor.dismiss(animated: false, completion: nil) }
        guard result.type == .photo else { return }
        guard let photoData = try? Data(contentsOf: result.mediaURL) else { return }
        guard let photo = UIImage(data: photoData) else { return }
        let asset = assets[currentIndex]
        asset._images[.edited] = result.isEdited ? photo : nil
        
        options.resources[currentIndex] = result.isEdited ? .image(photo) : .phAsset(asset.phAsset)
        super.update(options: options)
        
        // 选择当前照片
        if !manager.isUpToLimit {
            if !asset.isSelected {
                selectButtonTapped()
            }
        }
//        thumbnailPreviewView.reloadSelectionState() TODO : 本次
        delegate?.previewController(self, didSelected: currentIndex)
    }
}

#endif
