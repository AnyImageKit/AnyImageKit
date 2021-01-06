//
//  AssetPickerViewController+Capture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/3.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

#if ANYIMAGEKIT_ENABLE_CAPTURE

// MARK: - Capture
extension AssetPickerViewController {
    
    /// 打开相机
    func showCapture() {
        #if !targetEnvironment(simulator)
        var options = manager.options.captureOptions
        options.enableDebugLog = manager.options.enableDebugLog
        let controller = ImageCaptureController(options: options, delegate: self)
        present(controller, animated: true, completion: nil)
        #else
        let alert = UIAlertController(title: "Error", message: "Camera is unavailable on simulator", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        #endif
    }
    
    /// 添加拍照 Item
    func addCameraAssetIfNeeded() {
        guard let album = album, album.isCameraRoll else { return }
        if album.hasCamera { return }
        let options = manager.options
        let sortType = options.orderByDate
        if !options.captureOptions.mediaOptions.isEmpty {
            switch sortType {
            case .asc:
                album.addAsset(Asset(idx: Asset.cameraItemIdx, asset: .init(), selectOptions: options.selectOptions), atLast: true)
            case .desc:
                album.insertAsset(Asset(idx: Asset.cameraItemIdx, asset: .init(), selectOptions: options.selectOptions), at: 0, sort: options.orderByDate)
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
            if #available(iOS 14.0, *) {
                // iOS 14 将会监听相册，自动刷新
            } else {
                collectionView.insertItems(at: [IndexPath(item: album.assets.count-2, section: 0)])
            }
        case .desc:
            let asset = Asset(idx: 0, asset: phAsset, selectOptions: manager.options.selectOptions)
            album.insertAsset(asset, at: 1, sort: manager.options.orderByDate)
            addSuccess = manager.addSelectedAsset(asset)
            if #available(iOS 14.0, *) {
                // iOS 14 将会监听相册，自动刷新
            } else {
                collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
            }
        }
        updateVisibleCellState()
        toolBar.setEnable(true)
        if addSuccess {
            /// 拍照结束后，如果 limit=1 直接返回
            if manager.options.selectLimit == 1 {
                stopReloadAlbum = true
                delegate?.assetPickerDidFinishPicking(self)
            }
        }
    }
}

// MARK: - ImageCaptureControllerDelegate
extension AssetPickerViewController: ImageCaptureControllerDelegate {
    
    func imageCapture(_ capture: ImageCaptureController, didFinishCapturing result: CaptureResult) {
        capture.dismiss(animated: true, completion: nil)
        showWaitHUD()
        switch result.type {
        case .photo:
            trackObserver?.track(event: .takePhoto, userInfo: [:])
            manager.savePhoto(url: result.mediaURL) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                hideHUD()
            }
        case .video:
            trackObserver?.track(event: .takeVideo, userInfo: [:])
            manager.saveVideo(url: result.mediaURL) { [weak self] (result) in
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
