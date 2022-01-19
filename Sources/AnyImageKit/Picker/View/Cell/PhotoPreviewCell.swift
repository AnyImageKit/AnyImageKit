//
//  PhotoPreviewCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class PhotoPreviewCell: PreviewCell {
    
    /// 双击手势
    private lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    
    /// 双击放大图片时的目标比例
    var imageZoomScaleForDoubleTap: CGFloat = 2.0
    
    private var task: Task<Void, Error>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        scrollView.delegate = self
        // 双击手势
        contentView.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
    }
    
    /// 重置图片缩放比例
    override func reset() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
    
    override func optionsDidUpdate(options: PickerOptionsInfo) {
        accessibilityLabel = options.theme[string: .photo]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
    }
}

// MARK: - Function
extension PhotoPreviewCell {
    
    /// 加载图片
    func requestPhoto() {
        task?.cancel()
        task = Task {
            do {
                for try await result in asset.phAsset.loadPhotoLibraryImage(options: .library()) {
                    guard !Task.isCancelled else { return }
                    switch result {
                    case .progress(let progress):
                        self.setDownloadingProgress(progress)
                    case .success(let loadResult):
                        switch loadResult {
                        case .thumbnail(let image):
                            self.setImage(image)
                        case .preview(let image):
                            self.setDownloadingProgress(1.0)
                            self.setImage(image)
                        default:
                            break
                        }
                    }
                }
            } catch {
                _print(error)
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
