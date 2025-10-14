//
//  BrowserPreviewView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/10.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

public protocol BrowserPreviewViewDelegate: AnyObject {
    
    func previewDidBeginPan(_ preview: BrowserPreviewView)
    
    func preview(_ preview: BrowserPreviewView, didPanScale scale: CGFloat)
    
    func preview(_ preview: BrowserPreviewView, didEndPanWithExit isExit: Bool)
    
    func previewDidSingleTap(_ preview: BrowserPreviewView)
}

open class BrowserPreviewView: UIView, BrowserOptionsConfigurable {
    
    weak var delegate: BrowserPreviewViewDelegate?
    
    var isDownloaded: Bool = false
    
    public private(set) lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
//        if #available(iOS 26.0, *) {
//            view.topEdgeEffect.isHidden = true
//        }
        return view
    }()
    
    /// 显示图像
    public internal(set) lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.clipsToBounds = true
//        if #available(iOS 17.0, *) {
//            view.preferredImageDynamicRange = .high
//        }
        return view
    }()
    
    /// 下载进度
    public private(set) lazy var iCloudView: LoadingiCloudView = {
        let view = LoadingiCloudView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    /// 单击手势
    public private(set) lazy var singleTap: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(onSingleTap))
    }()
    
    /// 拖动手势
    public private(set) lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        return pan
    }()
    
    /// 双击手势
    private lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    
    /// 双击放大图片时的目标比例
    open var imageZoomScaleForDoubleTap: CGFloat = 2.0
    
    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    private var isFirstLayout: Bool = true
    private var needLayout: Bool = false

    private var containerSize: CGSize = .zero
    
    public var options: BrowserOptionsInfo = .init()
    public let contentSafeAreaLayoutGuide: UILayoutGuide
    
    init(_ contentSafeAreaLayoutGuide: UILayoutGuide) {
        self.contentSafeAreaLayoutGuide = contentSafeAreaLayoutGuide
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
        setupView()
        isAccessibilityElement = true
        NotificationCenter.default.addObserver(self, selector: #selector(containerSizeDidChange(_:)), name: .containerSizeDidChange, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if isFirstLayout {
            isFirstLayout = false
            setupLayout()
        }
        
        let newContainerSize = bounds.size
        if needLayout || containerSize != newContainerSize {
            needLayout = false
            layout()
        }
        containerSize = newContainerSize
    }
    
    // MARK: - Override
    
    /// Updates the view with new browser options.
    open func update(options: BrowserOptionsInfo) {
        self.options = options
        updateChildrenConfigurable(options: options)
    }
    
    /// Configures the view with a resource model.
    open func config(_ model: any BrowserResource) {
        model.loadImage { [weak self] result in
            guard let self else { return }
            if Thread.isMainThread {
                self.didLoadImage(result: result)
            } else {
                DispatchQueue.main.async {
                    self.didLoadImage(result: result)
                }
            }
        }
    }
    
    /// Sets up the initial layout constraints for the view.
    open func setupLayout() {
        iCloudView.snp.makeConstraints { maker in
            maker.top.equalTo(contentSafeAreaLayoutGuide).offset(16)
            maker.left.equalTo(contentSafeAreaLayoutGuide).offset(8)
            maker.height.equalTo(25)
        }
    }
    
    /// Re-layouts the view and its subviews.
    open func layout() {
        scrollView.frame = bounds
        scrollView.setZoomScale(1.0, animated: false)
        imageView.frame = fitFrame
        let minZoomScale = getDefaultScale()
        let maxZoomScale = getMaxZoomScale(with: minZoomScale)
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.setZoomScale(minZoomScale, animated: false)
    }
    
    /// Hides or shows the toolbar and other UI elements.
    open func hideToolBar(isHidden: Bool, isAnimated: Bool = true) {
        let animation = {
            self.iCloudView.alpha = isHidden ? 0 : 1
            self.layoutIfNeeded()
        }
        if isAnimated {
            UIView.animate(withDuration: 0.25, animations: animation)
        } else {
            animation()
        }
    }
    
    /// 计算contentSize应处于的中心位置
    open var centerOfContentSize: CGPoint {
        let deltaWidth = bounds.width - scrollView.contentSize.width
        let offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0
        let deltaHeight = bounds.height - scrollView.contentSize.height
        let offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0
        return CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                       y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    /// 取图片适屏size
    open var fitSize: CGSize {
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
    open var fitFrame: CGRect {
        let size = fitSize
        let x = (scrollView.bounds.width - size.width) > 0 ? (scrollView.bounds.width - size.width) * 0.5 : 0
        let y = (scrollView.bounds.height - size.height) > 0 ? (scrollView.bounds.height - size.height) * 0.5 : 0
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}

// MARK: - Notification
extension BrowserPreviewView {
    
    @objc private func containerSizeDidChange(_ sender: Notification) {
        layout()
    }
}

// MARK: - Private function
extension BrowserPreviewView {
    
    private func setupView() {
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        addSubview(iCloudView)
        
        // 添加手势
        addGestureRecognizer(singleTap)
        // 必须加在scrollView上。不能加在contentView上，否则长图下拉不能触发
        scrollView.addGestureRecognizer(pan)
        addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
    }
    
    /// 获取缩放比例
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
    
    func didLoadImage(result: Result<BrowserFetchResult, AnyImageError>) {
        switch result {
        case .success(let response):
            self.setDownloadingProgress(response.progress)
            if let image = response.image {
                self.imageView.image = image
                self.layout()
                self.needLayout = true
            }
        case .failure(_):
            self.imageView.image = nil
        }
    }
    
    /// 设置 iCloud 下载进度
    internal func setDownloadingProgress(_ progress: Double) {
        isDownloaded = progress == 1
        iCloudView.isHidden = progress == 1
        iCloudView.setProgress(progress)
        if progress == 1 {
//            NotificationCenter.default.post(name: .previewCellDidDownloadResource, object: asset)
        }
    }
}

// MARK: - Target
extension BrowserPreviewView {
    
    /// 响应单击
    @objc private func onSingleTap() {
        delegate?.previewDidSingleTap(self)
    }
    
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
    
    /// 响应拖动
    @objc private func onPan(_ pan: UIPanGestureRecognizer) {
        guard imageView.image != nil else {
            return
        }
        switch pan.state {
        case .began:
            beganFrame = imageView.frame
            beganTouch = pan.location(in: scrollView)
            delegate?.previewDidBeginPan(self)
        case .changed:
            let result = panResult(pan)
            imageView.frame = result.0
            // 通知代理，发生了缩放。代理可依scale值改变背景蒙板alpha值
            delegate?.preview(self, didPanScale: result.1)
        case .ended, .cancelled:
            imageView.frame = panResult(pan).0
            if pan.velocity(in: self).y > 0 {
                // dismiss
                delegate?.preview(self, didEndPanWithExit: true)
            } else {
                // 取消dismiss
                endPan()
            }
        default:
            endPan()
        }
    }
    
    private func panResult(_ pan: UIPanGestureRecognizer) -> (CGRect, CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: scrollView)
        let currentTouch = pan.location(in: scrollView)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / bounds.height))
        
        let width = beganFrame.size.width * scale
        let height = beganFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        // 即如果手势开始时，手指在图片X轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
        let xRate = (beganTouch.x - beganFrame.origin.x) / beganFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (beganTouch.y - beganFrame.origin.y) / beganFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    private func endPan() {
        delegate?.preview(self, didPanScale: 1.0)
        delegate?.preview(self, didEndPanWithExit: false)
        UIView.animate(withDuration: 0.25) {
            self.imageView.frame = self.beganFrame
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension BrowserPreviewView: UIGestureRecognizerDelegate {
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只响应pan手势
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = pan.velocity(in: self)
        // 向上滑动时，不响应手势
        if velocity.y < 0 {
            return false
        }
        // 横向滑动时，不响应pan手势
        if abs(Int(velocity.x)) > Int(velocity.y) {
            return false
        }
        // 向下滑动，如果图片顶部超出可视区域，不响应手势
        if scrollView.contentOffset.y > 0 {
            return false
        }
        // 响应允许范围内的下滑手势
        return true
    }
}

// MARK: - UIScrollViewDelegate
extension BrowserPreviewView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = centerOfContentSize
    }
}

extension Notification.Name {
    
    // TODO:
    static let previewCellDidDownloadResource = Notification.Name("org.AnyImageKit.Notification.Name.Picker.PreviewCellDidDownloadResource")
}
