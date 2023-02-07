//
//  PreviewCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol PreviewCellDelegate: AnyObject {
    
    /// 开始拖动
    func previewCellDidBeginPan(_ cell: PreviewCell)
    
    /// 拖动时回调。scale:缩放比率
    func previewCell(_ cell: PreviewCell, didPanScale scale: CGFloat)
    
    /// 结束拖动
    func previewCell(_ cell: PreviewCell, didEndPanWithExit isExit: Bool)
    
    /// 单击时回调
    func previewCellDidSingleTap(_ cell: PreviewCell)
    
    /// 获取工具栏的显示状态
    func previewCellGetToolBarHiddenState() -> Bool
}

class PreviewCell: UICollectionViewCell {
    
    weak var delegate: PreviewCellDelegate?
    
    var asset: Asset!
    var manager: PickerManager! {
        didSet {
            if oldValue == nil {
                update(options: manager.options)
            }
        }
    }
    
    var isDownloaded: Bool = false
    
    /// 内嵌容器
    /// 本类不能继承 UIScrollView，因为实测 UIScrollView 遵循了 UIGestureRecognizerDelegate 协议，而本类也需要遵循此协议
    /// 若继承 UIScrollView 则会覆盖 UIScrollView 的协议实现，故只内嵌而不继承
    private(set) lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()
    
    /// 显示图像
    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.clipsToBounds = true
        return view
    }()
    
    /// 下载进度
    private(set) lazy var iCloudView: LoadingiCloudView = {
        let view = LoadingiCloudView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    /// 单击手势
    private(set) lazy var singleTap: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(onSingleTap))
    }()
    
    /// 拖动手势
    private(set) lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        return pan
    }()
    
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
        let x = (scrollView.bounds.width - size.width) > 0 ? (scrollView.bounds.width - size.width) * 0.5 : 0
        let y = (scrollView.bounds.height - size.height) > 0 ? (scrollView.bounds.height - size.height) * 0.5 : 0
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    private var needLayout: Bool = false

    private var containerSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setupView()
        isAccessibilityElement = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(containerSizeDidChange(_:)), name: .containerSizeDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iCloudView.reset()
    }
    
    // MARK: - Function
    
    /// 设置图片
    func setImage(_ image: UIImage?) {
        imageView.image = image
        if image != nil {
            layout()
            needLayout = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let newContainerSize = contentView.bounds.size
        if needLayout || containerSize != newContainerSize {
            needLayout = false
            layout()
        }
        containerSize = newContainerSize
    }
    
    /// 重新布局
    internal func layout() {
        scrollView.frame = contentView.bounds
        scrollView.setZoomScale(1.0, animated: false)
        imageView.frame = fitFrame
        let minZoomScale = getDefaultScale()
        let maxZoomScale = getMaxZoomScale(with: minZoomScale)
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.setZoomScale(minZoomScale, animated: false)
    }
    
    /// 设置 iCloud 下载进度
    internal func setDownloadingProgress(_ progress: Double) {
        isDownloaded = progress == 1
        iCloudView.isHidden = progress == 1
        iCloudView.setProgress(progress)
        if progress == 1 {
            NotificationCenter.default.post(name: .previewCellDidDownloadResource, object: asset)
        }
    }
    
    // MARK: - Override
    
    func reset() { }
    
    func singleTapped() {
        delegate?.previewCellDidSingleTap(self)
    }
    
    func panBegin() {
        delegate?.previewCellDidBeginPan(self)
    }
    
    func panScale(_ scale: CGFloat) {
        delegate?.previewCell(self, didPanScale: scale)
    }
    
    func panEnded(_ exit: Bool) {
        delegate?.previewCell(self, didEndPanWithExit: exit)
    }
    
    /// 通知子类更新配置
    /// 由于 update options 方法来自协议，无法在子类重载，所以需要这个方法通知子类
    func optionsDidUpdate(options: PickerOptionsInfo) { }
}

// MARK: - PickerOptionsConfigurable
extension PreviewCell: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        optionsDidUpdate(options: options)
        updateChildrenConfigurable(options: options)
    }
}

// MARK: - Notification
extension PreviewCell {
    
    @objc private func containerSizeDidChange(_ sender: Notification) {
        layout()
    }
}

// MARK: - Private function
extension PreviewCell {
    
    private func setupView() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        contentView.addSubview(iCloudView)
        
        iCloudView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(100)
            maker.left.equalToSuperview().offset(10)
            maker.height.equalTo(25)
        }
        
        // 添加手势
        contentView.addGestureRecognizer(singleTap)
        // 必须加在scrollView上。不能加在contentView上，否则长图下拉不能触发
        scrollView.addGestureRecognizer(pan)
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
}

// MARK: - Target
extension PreviewCell {
    /// 响应单击
    @objc private func onSingleTap() {
        singleTapped()
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
            panBegin()
        case .changed:
            let result = panResult(pan)
            imageView.frame = result.0
            // 通知代理，发生了缩放。代理可依scale值改变背景蒙板alpha值
            panScale(result.1)
        case .ended, .cancelled:
            imageView.frame = panResult(pan).0
            if pan.velocity(in: self).y > 0 {
                // dismiss
                panEnded(true)
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
        panScale(1.0)
        panEnded(false)
        UIView.animate(withDuration: 0.25) {
            self.imageView.frame = self.beganFrame
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PreviewCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
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

extension Notification.Name {
    
    static let previewCellDidDownloadResource = Notification.Name("org.AnyImageKit.Notification.Name.Picker.PreviewCellDidDownloadResource")
}
