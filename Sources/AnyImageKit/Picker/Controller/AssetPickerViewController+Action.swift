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
    
    @objc func previewButtonTapped(_ sender: UIButton) {
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
    
    @objc func limitedButtonTapped(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            trackObserver?.track(event: .pickerLimitedLibrary, userInfo: [:])
        }
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
        //            if #available(iOS 18.0, *) {
        //                guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCell else { return }
        //                controller.preferredTransition = .zoom(sourceViewProvider: { context in
        //                    return cell
        //                })
        //            }
        
        self.previewController = controller
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func browser(_ browser: BrowserController, relatedViewAt index: Int) -> UIView? {
        let sourceType = PhotoPreviewController.SourceType(rawValue: browser.view.tag) ?? .album
        switch sourceType {
        case .album:
            return (section.cellForItem(at: index) as? AssetCell)?.imageView
        case .selectedAssets:
            return (section.cellForItem(at: manager.selectedAssets[index].idx + section.itemOffset) as? AssetCell)?.imageView
        }
    }
}
