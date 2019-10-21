//
//  LivePhotoPreviewCell.swift
//  AnyImagePicker
//
//  Created by Ray on 2019/10/22.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import PhotosUI

final class LivePhotoPreviewCell: PreviewCell {
    
    private lazy var livePhotoView: PHLivePhotoView = {
        let view = PHLivePhotoView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(livePhotoView)
        
        livePhotoView.snp.makeConstraints { maker in
            maker.edges.equalTo(imageView)
        }
    }
}

extension LivePhotoPreviewCell {
    
    func requestLivePhoto() {
        let id = asset.phAsset.localIdentifier
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let options = LivePhotoFetchOptions(targetSize: .zero) { (progress, error, isAtEnd, info) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    _print("Download live photo from iCloud: \(progress)")
                    // TODO: Set progress
                }
            }
            PhotoManager.shared.requestLivePhoto(for: self.asset.phAsset, options: options) { (result) in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.livePhotoView.livePhoto = response.livePhoto
                    }
                case .failure(let error):
                    _print(error.localizedDescription)
                }
            }
        }
    }
}
