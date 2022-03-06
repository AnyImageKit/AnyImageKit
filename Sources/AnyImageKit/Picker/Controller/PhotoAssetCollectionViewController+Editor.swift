//
//  AssetPickerViewController+Editor.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/23.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

#if ANYIMAGEKIT_ENABLE_EDITOR

extension PhotoAssetCollectionViewController {
    
    func openEditor(asset: Asset<PHAsset>, indexPath: IndexPath) {
        Task {
            showWaitHUD(options.theme[string: .loading])
            for try await result in asset.loadImage() {
                switch result {
                case .progress(let progress):
                    showWaitHUD(options.theme[string: .pickerDownloadingFromiCloud] + "\(Int(progress * 100))%")
                case .success(let loadResult):
                    switch loadResult {
                    case .preview(let image):
                        hideHUD()
                        if asset.mediaType == .photo {
                            var photoOptions = options.editorPhotoOptions
                            photoOptions.enableDebugLog = options.enableDebugLog
                            photoOptions.cacheIdentifier = asset.identifier.replacingOccurrences(of: "/", with: "-")
                            let controller = ImageEditorController(photo: image, options: photoOptions, delegate: self)
                            controller.tag = indexPath.row
                            present(controller, animated: true, completion: nil)
                        } else if asset.phAsset.mediaType == .video {
                            var videoOptions = options.editorVideoOptions
                            videoOptions.enableDebugLog = options.enableDebugLog
                            let controller = ImageEditorController(video: asset.phAsset, placeholderImage: image, options: videoOptions, delegate: self)
                            controller.tag = indexPath.row
                            present(controller, animated: false, completion: nil)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}

// MARK: - ImageEditorControllerDelegate
extension PhotoAssetCollectionViewController: ImageEditorControllerDelegate {
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing result: EditorResult) {
        editor.dismiss(animated: true, completion: nil)
//        guard result.type == .photo else { return }
//        guard let photoData = try? Data(contentsOf: result.mediaURL) else { return }
//        guard let photo = UIImage(data: photoData) else { return }
//        guard let photoLibrary = photoLibrary else { return }
//        let index = editor.tag
//        let indexPath = IndexPath(item: index, section: 0)
//        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoAssetCell else { return }
//        guard let asset = photoLibrary[index].asset else { return }
//        
//        cell.setContent(asset: asset)
//        if !asset.isSelected {
//            setSelected(index)
//        }
    }
}

#endif
