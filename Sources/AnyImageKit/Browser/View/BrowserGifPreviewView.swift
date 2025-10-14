//
//  BrowserGifPreviewView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/13.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import Kingfisher
import MobileCoreServices

open class BrowserGifPreviewView: BrowserPreviewView {
    
    private var didLoadGif = false
    
    override init(_ contentSafeAreaLayoutGuide: UILayoutGuide) {
        super.init(contentSafeAreaLayoutGuide)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        imageView.removeFromSuperview()
        imageView = AnimatedImageView()
        imageView.contentMode = .scaleToFill
        scrollView.addSubview(imageView)
    }
    
    /// 取图片适屏size
    open override var fitSize: CGSize {
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
    open override var fitFrame: CGRect {
        let size = fitSize
        let x = (scrollView.bounds.width - size.width) > 0 ? (scrollView.bounds.width - size.width) * 0.5 : 0
        let y = (scrollView.bounds.height - size.height) > 0 ? (scrollView.bounds.height - size.height) * 0.5 : 0
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    open override func config(_ model: BrowserResource) {
        model.loadImage { [weak self] result in
            guard let self, !self.didLoadGif else { return }
            if Thread.isMainThread {
                self.didLoadImage(result: result)
            } else {
                DispatchQueue.main.async {
                    self.didLoadImage(result: result)
                }
            }
        }
        
        switch model {
        case .phAsset(let asset):
            let options = PhotoDataFetchOptions(version: .current, isNetworkAccessAllowed: true) { (progress, error, isAtEnd, info) in
                DispatchQueue.main.async {
                    self.setDownloadingProgress(progress)
                }
            }
            ExportTool.requestPhotoData(for: asset, options: options) { result, requestID in
                switch result {
                case .success(let response):
                    guard UTTypeConformsTo(response.dataUTI as CFString, kUTTypeGIF) else {
                        return
                    }
                    let creatingOptions = ImageCreatingOptions()
                    guard let image = KingfisherWrapper<UIImage>.animatedImage(data: response.data, options: creatingOptions) else {
                        return
                    }
                    self.didLoadGif = true
                    self.imageView.image = image
                    self.imageView.frame = self.fitFrame
                    self.setDownloadingProgress(1.0)
                case .failure(let error):
                    _print(error)
                }
            }
        default:
            break
        }
    }
}
