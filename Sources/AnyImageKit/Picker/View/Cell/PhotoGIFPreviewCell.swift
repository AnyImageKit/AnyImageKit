//
//  PhotoGIFPreviewCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Kingfisher

final class PhotoGIFPreviewCell: PreviewCell {
    
    /// 取图片适屏size
    override var fitSize: CGSize {
        guard let image = imageView.image else { return CGSize.zero }
        let screenSize = ScreenHelper.mainBounds.size
        if image.size.width > screenSize.width {
            let width = scrollView.bounds.width
            let scale = image.size.height / image.size.width
            return CGSize(width: width, height: scale * width)
        }
        return image.size
    }
    
    /// 取图片适屏frame
    override var fitFrame: CGRect {
        let size = fitSize
        let x = (scrollView.bounds.width - size.width) > 0 ? (scrollView.bounds.width - size.width) * 0.5 : 0
        let y = (scrollView.bounds.height - size.height) > 0 ? (scrollView.bounds.height - size.height) * 0.5 : 0
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        imageView.removeFromSuperview()
        imageView = AnimatedImageView()
        imageView.contentMode = .scaleToFill
        scrollView.addSubview(imageView)
    }
    
    override func optionsDidUpdate(options: PickerOptionsInfo) {
        accessibilityLabel = options.theme[string: .photo]
    }
}

// MARK: - Function
extension PhotoGIFPreviewCell {
    
    /// 加载 GIF
    func requestGIF() {
        let id = asset.identifier
        let options = PhotoGIFFetchOptions() { (progress, error, isAtEnd, info) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.asset.identifier == id else { return }
                _print("Download GIF from iCloud: \(progress)")
                self.setDownloadingProgress(progress)
            }
        }
        manager.requsetPhotoGIF(for: asset.phAsset, options: options) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard self.asset.identifier == id else { return }
                self.imageView.image = response.image
                self.imageView.frame = self.fitFrame
                self.setDownloadingProgress(1.0)
            case .failure(let error):
                _print(error)
            }
        }
    }
}
