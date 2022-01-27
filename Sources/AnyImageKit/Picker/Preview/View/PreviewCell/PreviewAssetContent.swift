//
//  PreviewAssetContent.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/27.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

enum PreviewAssetContentPanState {
    
    case begin
    case scale(CGFloat)
    case end(Bool)
}

protocol PreviewAssetContent {
    
    var scrollView: UIScrollView { get }
    var centerOfContentSize: CGPoint { get }
    var fitSize: CGSize { get }
    var fitFrame: CGRect { get }
    
    func reset()
    func layout()
    func layoutDidUpdate()
    
    var imageView: UIImageView { get }
    func makeImageView() -> UIImageView
    func setImage(_ image: UIImage)
    
    var loadingView: LoadingiCloudView { get }
    func updateLoadingProgress(_ progress: Double)
    func loadingProgressDidUpdate(_ progress: Double)
}

extension PreviewAssetContent where Self: UICollectionViewCell {
    
    /// 计算contentSize应处于的中心位置
    var centerOfContentSize: CGPoint {
        let deltaWidth = bounds.width - scrollView.contentSize.width
        let offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0
        let deltaHeight = bounds.height - scrollView.contentSize.height
        let offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0
        return CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                       y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    /// 取图片适屏size
    var fitSize: CGSize {
        guard let image = imageView.image else { return CGSize.zero }
        let screenSize = ScreenHelper.mainBounds.size
        let scale = image.size.height / image.size.width
        var size = CGSize(width: screenSize.width, height: scale * screenSize.width)
        if size.width > size.height {
            size.width = size.width * screenSize.height / size.height
            size.height = screenSize.height
        }
        return size
    }
    
    /// 取图片适屏frame
    var fitFrame: CGRect {
        let size = fitSize
        let y = (scrollView.bounds.height - size.height) > 0 ? (scrollView.bounds.height - size.height) * 0.5 : 0
        return CGRect(x: 0, y: y, width: size.width, height: size.height)
    }
    
    func reset() {
        
    }
    
    func layout() {
        scrollView.frame = contentView.bounds
        scrollView.setZoomScale(1.0, animated: false)
        imageView.frame = fitFrame
        let minZoomScale = getDefaultScale()
        let maxZoomScale = getMaxZoomScale(with: minZoomScale)
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.setZoomScale(minZoomScale, animated: false)
        layoutDidUpdate()
    }
    
    func layoutDidUpdate() {
        
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView(frame: .zero)
        view.clipsToBounds = true
        return view
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
        layout()
    }
    
    func updateLoadingProgress(_ progress: Double) {
        loadingView.isHidden = progress == 1
        loadingView.setProgress(progress)
        loadingProgressDidUpdate(progress)
    }
    
    func loadingProgressDidUpdate(_ progress: Double) {
        
    }
}

extension PreviewAssetContent where Self: UICollectionViewCell {
    
    private func getDefaultScale() -> CGFloat {
        guard let image = imageView.image else { return 1.0 }
        let width = scrollView.bounds.width
        let scale = image.size.height / image.size.width
        let size = CGSize(width: width, height: scale * width)
        let screenSize = ScreenHelper.mainBounds.size
        if size.width > size.height {
            return size.height / screenSize.height
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            let height = scrollView.bounds.height
            let scale = image.size.width / image.size.height
            let size = CGSize(width: height * scale, height: height)
            if size.height > size.width {
                return size.width / screenSize.width
            }
        }
        return 1.0
    }
    
    private func getMaxZoomScale(with minZoomScale: CGFloat) -> CGFloat {
        guard let image = imageView.image else { return 1.0 }
        var maxZoomScale = (image.size.width / ScreenHelper.mainBounds.width) * 2
        maxZoomScale = maxZoomScale / (1.0 / minZoomScale)
        return maxZoomScale < 1.0 ? 1.0 : maxZoomScale
    }
}
