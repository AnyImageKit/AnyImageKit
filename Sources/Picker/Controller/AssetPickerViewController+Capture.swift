//
//  AssetPickerViewController+Capture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/3.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

#if ANYIMAGEKIT_ENABLE_CAPTURE

// MARK: - Capture
extension AssetPickerViewController {
    
    /// 打开相机
    func showCapture() {
        #if !targetEnvironment(simulator)
        let controller = ImageCaptureController(options: manager.options.captureOptions, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
        #else
        let alert = UIAlertController(title: "Error", message: "Camera is unavailable on simulator", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        #endif
    }
    
    /// 添加拍照 Item
    func addCameraAssetIfNeed() {
        guard let album = album, album.isCameraRoll else { return }
        let options = manager.options
        let sortType = options.orderByDate
        if !options.captureOptions.mediaOptions.isEmpty {
            switch sortType {
            case .asc:
                album.addAsset(Asset(idx: -1, asset: .init(), selectOptions: options.selectOptions), atLast: true)
            case .desc:
                album.insertAsset(Asset(idx: -1, asset: .init(), selectOptions: options.selectOptions), at: 0, sort: options.orderByDate)
            }
        }
    }
    
    /// 拍照结束后，插入 PHAsset
    func addPHAsset(_ phAsset: PHAsset) {
        guard let album = album else { return }
        let sortType = manager.options.orderByDate
        let addSuccess: Bool
        switch sortType {
        case .asc:
            let asset = Asset(idx: album.assets.count-1, asset: phAsset, selectOptions: manager.options.selectOptions)
            album.addAsset(asset, atLast: false)
            addSuccess = manager.addSelectedAsset(asset)
            collectionView.insertItems(at: [IndexPath(item: album.assets.count-2, section: 0)])
        case .desc:
            let asset = Asset(idx: 0, asset: phAsset, selectOptions: manager.options.selectOptions)
            album.insertAsset(asset, at: 1, sort: manager.options.orderByDate)
            addSuccess = manager.addSelectedAsset(asset)
            collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
        }
        updateVisibleCellState()
        toolBar.setEnable(true)
        if addSuccess {
            /// 拍照结束后，如果 limit=1 直接返回
            if manager.options.selectLimit == 1 {
                delegate?.assetPickerDidFinishPicking(self)
            }
        }
    }
}

// MARK: - ImageCaptureControllerDelegate
extension AssetPickerViewController: ImageCaptureControllerDelegate {
    
    func imageCapture(_ capture: ImageCaptureController, didFinishCapturing media: URL, type: MediaType) {
        capture.dismiss(animated: true, completion: nil)
        showWaitHUD()
        switch type {
        case .photo:
            manager.savePhoto(url: media) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                hideHUD()
            }
        case .video:
            manager.saveVideo(url: media) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                hideHUD()
            }
        case .photoLive, .photoGIF:
            // Not support yet
            break
        }
    }
}

#endif
