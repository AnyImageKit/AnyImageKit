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
    
    /* 由于监控了相册变化，该方法实际已经不需要了
    /// 拍照结束后，插入 PHAsset
    func addPHAsset(_ phAsset: PHAsset) {
        let asset = Asset(phAsset: phAsset, selectOption: manager.options.selectOptions)
        let addSuccess = manager.addSelectedAsset(asset)
        updateVisibleCellState()
        toolBar.setEnable(true)
        if addSuccess {
            /// 拍照结束后，如果 limit=1 直接返回
            if manager.options.selectLimit == 1 {
                stopReloadAlbum = true
                delegate?.assetPickerDidFinishPicking(self)
            }
        }
    }*/
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
                    print(asset) // FIXME: self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                self?.hideHUD()
            }
        case .video:
            trackObserver?.track(event: .takeVideo, userInfo: [:])
            manager.saveVideo(url: result.mediaURL) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    print(asset) // FIXME: self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                self?.hideHUD()
            }
        case .photoLive, .photoGIF:
            // Not support yet
            break
        }
    }
}

#endif
