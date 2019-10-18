//
//  PhotoPreviewCell.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class PhotoPreviewCell: PreviewCell {
    
    /// 双击手势
    lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    
    /// 捏合手势放大图片时的最大允许比例
    var imageMaximumZoomScale: CGFloat = 2.0 {
        didSet {
            self.scrollView.maximumZoomScale = imageMaximumZoomScale
        }
    }
    
    /// 双击放大图片时的目标比例
    var imageZoomScaleForDoubleTap: CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = imageMaximumZoomScale
        
        // 双击手势
        contentView.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
    }
    
    /// 重置图片缩放比例
    override func reset() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
}

// MARK: - function
extension PhotoPreviewCell {
    
    /// 加载图片
    func requestPhoto() {
        if imageView.image == nil { // thumbnail
            let options = PhotoFetchOptions(sizeMode: .resize(100*UIScreen.main.nativeScale), needCache: false)
            PhotoManager.shared.requestPhoto(for: asset.phAsset, options: options, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if self.imageView.image == nil {
                        self.setImage(response.image)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }
        
        let options = PhotoFetchOptions(sizeMode: .preview)
        PhotoManager.shared.requestPhoto(for: asset.phAsset, options: options) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if !response.isDegraded {
                    self.setImage(response.image)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Target
extension PhotoPreviewCell {
    
    /// 响应双击
    @objc private func onDoubleTap(_ dbTap: UITapGestureRecognizer) {
        // 如果当前没有任何缩放，则放大到目标比例
        // 否则重置到原比例
        if scrollView.zoomScale == 1.0 {
            if scrollView.minimumZoomScale == scrollView.zoomScale {
                // 以点击的位置为中心，放大
                let pointInView = dbTap.location(in: imageView)
                let w = scrollView.bounds.size.width / imageZoomScaleForDoubleTap
                let h = scrollView.bounds.size.height / imageZoomScaleForDoubleTap
                let x = pointInView.x - (w / 2.0)
                let y = pointInView.y - (h / 2.0)
                scrollView.zoom(to: CGRect(x: x, y: y, width: w, height: h), animated: true)
            } else {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
        } else if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoPreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = centerOfContentSize
    }
}
