//
//  AssetPickerViewController+Capture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/3.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
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
        let asset: Asset
        switch sortType {
        case .asc:
            asset = Asset(idx: album.assets.count-1, asset: phAsset, selectOptions: manager.options.selectOptions)
            album.addAsset(asset, atLast: false)
            if #available(iOS 14.0, *) {
                // iOS 14 将会监听相册，自动刷新
            } else {
                collectionView.performBatchUpdates { [weak self] in
                    self?.collectionView.insertItems(at: [IndexPath(item: album.assets.count-2, section: 0)])
                } completion: { [weak self] _ in
                    self?.collectionView.reloadData()
                }
            }
        case .desc:
            asset = Asset(idx: 0, asset: phAsset, selectOptions: manager.options.selectOptions)
            album.insertAsset(asset, at: 1, sort: manager.options.orderByDate)
            if #available(iOS 14.0, *) {
                // iOS 14 将会监听相册，自动刷新
            } else {
                collectionView.performBatchUpdates { [weak self] in
                    self?.collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
                } completion: { [weak self] _ in
                    self?.collectionView.reloadData()
                }
            }
        }
        
        updateVisibleCellState()
        toolBar.setEnable(true)
        
        let result = manager.addSelectedAsset(asset)
        if result.success {
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
        view.hud.show()
        switch result.type {
        case .photo:
            trackObserver?.track(event: .pickerTakePhoto, userInfo: [:])
            manager.savePhoto(url: result.mediaURL) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                self?.view.hud.hide()
            }
        case .video:
            trackObserver?.track(event: .pickerTakeVideo, userInfo: [:])
            manager.saveVideo(url: result.mediaURL) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                self?.view.hud.hide()
            }
        case .photoLive, .photoGIF:
            // Not support yet
            break
        }
    }
}

#endif
