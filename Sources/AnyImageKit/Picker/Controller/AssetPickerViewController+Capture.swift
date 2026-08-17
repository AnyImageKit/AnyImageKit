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
    func openCapture() {
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
        if !options.captureOptions.mediaOptions.isEmpty {
            album.addCameraAsset(Asset(idx: Asset.cameraItemIdx, asset: .init(), selectOptions: options.selectOptions))
        }
    }
    
    /// 拍照结束后，插入 PHAsset
    func addPHAsset(_ phAsset: PHAsset) {
        guard let album = album else { return }
        let asset = Asset(idx: 0, asset: phAsset, selectOptions: manager.options.selectOptions)
        album.cache(asset)
        
        updateVisibleCellState()
        toolBar.setEnable(true)
        
        let result = manager.addSelectedAsset(asset)
        if result.success {
            /// 拍照结束后，如果 limit=1 直接返回
            if manager.options.selectLimit == 1 {
                stopReloadAlbum = true
                delegate?.assetPickerDidFinishPicking(self)
            } else {
                reloadAlbum(album)
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
