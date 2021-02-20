//
//  AssetPickerViewController+Editor.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/23.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

#if ANYIMAGEKIT_ENABLE_EDITOR

extension AssetPickerViewController {
    
    func canOpenEditor(with asset: Asset) -> Bool {
        asset.check(disable: manager.options.disableRules)
        if case .disable(let rule) = asset.state {
            let message = rule.alertMessage(for: asset)
            showAlert(message: message)
            return false
        }
        if asset.phAsset.mediaType == .image && manager.options.editorOptions.contains(.photo) {
            return true
        } else if asset.phAsset.mediaType == .video && manager.options.editorOptions.contains(.video) {
            return true
        }
        return false
    }
    
    func openEditor(with asset: Asset, indexPath: IndexPath) {
        if asset.phAsset.mediaType == .image {
            if let image = asset._images[.initial] {
                showEditor(image, identifier: asset.phAsset.localIdentifier, tag: indexPath.item)
            } else {
                showWaitHUD(BundleHelper.localizedString(key: "LOADING", module: .core))
                let options = _PhotoFetchOptions(sizeMode: .preview(manager.options.largePhotoMaxWidth)) { (progress, error, isAtEnd, info) in
                    DispatchQueue.main.async { [weak self] in
                        _print("Downloading photo from iCloud: \(progress)")
                        self?.showWaitHUD(BundleHelper.localizedString(key: "DOWNLOADING_FROM_ICLOUD", module: .picker) + "\(Int(progress * 100))%")
                    }
                }
                manager.requestPhoto(for: asset.phAsset, options: options) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        if !response.isDegraded {
                            self.hideHUD()
                            self.showEditor(response.image, identifier: asset.phAsset.localIdentifier, tag: indexPath.item)
                        }
                    case .failure(let error):
                        self.hideHUD()
                        _print(error)
                    }
                }
            }
        } else if asset.phAsset.mediaType == .video {
            manager.cancelFetch(for: asset.phAsset.localIdentifier)
            var videoOptions = manager.options.editorVideoOptions
            videoOptions.enableDebugLog = manager.options.enableDebugLog
            let image = asset._images[.initial]
            let controller = ImageEditorController(video: asset.phAsset, placeholderImage: image, options: videoOptions, delegate: self)
            present(controller, animated: false, completion: nil)
        }
    }
    
    private func showEditor(_ image: UIImage, identifier: String, tag: Int) {
        var options = manager.options.editorPhotoOptions
        options.enableDebugLog = manager.options.enableDebugLog
        options.cacheIdentifier = identifier.replacingOccurrences(of: "/", with: "-")
        let controller = ImageEditorController(photo: image, options: options, delegate: self)
        controller.tag = tag
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - ImageEditorControllerDelegate
extension AssetPickerViewController: ImageEditorControllerDelegate {
    
    func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.dismiss(animated: true, completion: nil)
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
        editor.dismiss(animated: true, completion: nil)
        guard result.type == .photo else { return }
        guard let photoData = try? Data(contentsOf: result.mediaURL) else { return }
        guard let photo = UIImage(data: photoData) else { return }
        guard let album = album else { return }
        guard let cell = collectionView.cellForItem(at: IndexPath(item: editor.tag, section: 0)) as? AssetCell else { return }
        
        let asset = album.assets[editor.tag]
        asset._images[.edited] = result.isEdited ? photo : nil
        cell.setContent(asset, manager: manager)
        if !asset.isSelected { // Select
            selectItem(editor.tag)
            if manager.options.selectLimit == 1 && manager.selectedAssets.count == 1 {
                doneButtonTapped(toolBar.doneButton)
            }
        }
    }
}

#endif
