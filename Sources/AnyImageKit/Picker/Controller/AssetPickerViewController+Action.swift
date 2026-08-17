//
//  AssetPickerViewController+Action.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/17.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import PhotosUI

extension AssetPickerViewController {
    
    @objc func titleViewTapped(_ sender: PickerArrowButton) {
        let controller = AlbumPickerViewController(manager: manager)
        controller.album = album
        controller.albums = albums
        controller.delegate = self
        let presentationController = MenuDropDownPresentationController(presentedViewController: controller, presenting: self)
        let isFullScreen = ScreenHelper.mainBounds.height == (navigationController?.view ?? view).frame.height
        presentationController.isFullScreen = isFullScreen
        presentationController.cornerRadius = 8
        presentationController.corners = [.bottomLeft, .bottomRight]
        controller.transitioningDelegate = presentationController
        self.albumsPicker = controller
        present(controller, animated: true, completion: nil)
        trackObserver?.track(event: .pickerSwitchAlbum, userInfo: [:])
    }
    
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.assetPickerDidCancel(self)
        trackObserver?.track(event: .pickerCancel, userInfo: [:])
    }
    
    @objc func previewButtonTapped() {
        manager.lastSelectedAssets = manager.selectedAssets
        if let asset = manager.selectedAssets.first {
            openPreview(asset: asset, assets: manager.selectedAssets, index: 0, sourceType: .selectedAssets)
        }
        trackObserver?.track(event: .pickerPreview, userInfo: [:])
    }
    
    @objc func originalImageButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        manager.useOriginalImage = sender.isSelected
        trackObserver?.track(event: .pickerOriginalImage, userInfo: [.isOn: sender.isSelected, .page: AnyImagePage.pickerAsset])
    }
    
    @objc func doneButtonTapped(_ sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false
        stopReloadAlbum = true
        delegate?.assetPickerDidFinishPicking(self)
        trackObserver?.track(event: .pickerDone, userInfo: [.page: AnyImagePage.pickerAsset])
    }
    
    @objc func lgDoneButtonTapped(_ sender: UIBarButtonItem) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false
        stopReloadAlbum = true
        delegate?.assetPickerDidFinishPicking(self)
        trackObserver?.track(event: .pickerDone, userInfo: [.page: AnyImagePage.pickerAsset])
    }
    
    @objc func limitedButtonTapped(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            trackObserver?.track(event: .pickerLimitedLibrary, userInfo: [:])
        }
    }
}

extension AssetPickerViewController {
    
    func toolBarSetEnable(_ enable: Bool) {
        if #available(iOS 26.0, *), !manager.options.designRequiresCompatibility {
            lgView.previewButton.isEnabled = enable
            lgView.doneButton.isEnabled = enable
            return
        }
        toolBar.setEnable(enable)
    }
}

extension AssetPickerViewController: BrowserControllerDelegate {
    
    func openPreview(asset: Asset, assets: [Asset], index: Int, sourceType: PhotoPreviewController.SourceType) {
        var options = BrowserOptionsInfo()
        options.index = index
        options.resources = assets.map {
            if let image = $0._images[.edited] {
                return .image(image)
            } else {
                return .phAsset($0.phAsset)
            }
        }
        options.placeholdImage = asset.placeholdImage
        options.phAssetSupportedTypes = manager.options.selectOptions
        let controller = PhotoPreviewController(manager: manager, sourceType: sourceType, assets: assets, options: options, browserDelegate: self)
        controller.view.tag = sourceType.rawValue
        
        self.previewController = controller
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func browser(_ browser: BrowserController, relatedViewAt index: Int) -> UIView? {
        let sourceType = PhotoPreviewController.SourceType(rawValue: browser.view.tag) ?? .album
        switch sourceType {
        case .album:
            guard let controller = previewController,
                  controller.assets.indices.contains(index),
                  let idx = displayIndex(for: controller.assets[index]) else {
                return nil
            }
            return (section.cellForItem(at: idx) as? AssetCell)?.imageView
        case .selectedAssets:
            guard manager.selectedAssets.indices.contains(index),
                  let idx = displayIndex(for: manager.selectedAssets[index]) else {
                return nil
            }
            return (section.cellForItem(at: idx) as? AssetCell)?.imageView
        }
    }
}
