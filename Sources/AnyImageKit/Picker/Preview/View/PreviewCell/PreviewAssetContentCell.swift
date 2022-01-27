//
//  PreviewAssetContentCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

class PreviewAssetContentCell: UICollectionViewCell, PreviewAssetContent {
    
    private let sinageTapSubject: PassthroughSubject<Void, Never> = .init()
    private let panSubject: PassthroughSubject<PreviewAssetContentPanState, Never> = .init()
    
    /// 内嵌容器
    /// 本类不能继承 UIScrollView，因为实测 UIScrollView 遵循了 UIGestureRecognizerDelegate 协议，而本类也需要遵循此协议
    /// 若继承 UIScrollView 则会覆盖 UIScrollView 的协议实现，故只内嵌而不继承
    private(set) lazy var scrollView: UIScrollView = makeScrollView()
    private(set) lazy var imageView: UIImageView = makeImageView()
    private(set) lazy var loadingView: LoadingiCloudView = makeLoadingView()
    private(set) lazy var singleTap: UITapGestureRecognizer = makeSingleTapGesture()
    private(set) lazy var pan: UIPanGestureRecognizer = makePanGesture()
    
    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingView.reset()
    }
    
    // MARK: - Function
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice.current.userInterfaceIdiom == .pad { // Optimize performance, fit size classes
            layout()
        }
    }
    
    /// 通知子类更新配置
    /// 由于 update options 方法来自协议，无法在子类重载，所以需要这个方法通知子类
    func optionsDidUpdate(options: PickerOptionsInfo) { }
}

// MARK: - PreviewAssetContent
extension PreviewAssetContentCell {
    
    func sendSingleTappedEvent() {
        sinageTapSubject.send()
    }
    
    func sendPanEvent(state: PreviewAssetContentPanState) {
        panSubject.send(state)
    }
}

// MARK: - Publisher
extension PreviewAssetContentCell {
    
    var singleTapEvent: AnyPublisher<Void, Never> {
        sinageTapSubject.eraseToAnyPublisher()
    }
    
    var panEvent: AnyPublisher<PreviewAssetContentPanState, Never> {
        panSubject.eraseToAnyPublisher()
    }
}

// MARK: - PickerOptionsConfigurable
extension PreviewAssetContentCell: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        optionsDidUpdate(options: options)
        updateChildrenConfigurable(options: options)
    }
}

// MARK: - UI Setup
extension PreviewAssetContentCell {
    
    private func setupView() {
        isAccessibilityElement = true
        backgroundColor = UIColor.clear
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        contentView.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(100)
            maker.left.equalToSuperview().offset(10)
            maker.height.equalTo(25)
        }
        
        // 添加手势
        contentView.addGestureRecognizer(singleTap)
        // 必须加在scrollView上。不能加在contentView上，否则长图下拉不能触发
        scrollView.addGestureRecognizer(pan)
    }
    
    private func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }
    
    private func makeLoadingView() -> LoadingiCloudView {
        let view = LoadingiCloudView(frame: .zero)
        view.isHidden = true
        return view
    }
    
    private func makeSingleTapGesture() -> UITapGestureRecognizer {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
        gesture.numberOfTapsRequired = 1
        return gesture
    }
    
    private func makePanGesture() -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        gesture.delegate = self
        return gesture
    }
}

// MARK: - Action
extension PreviewAssetContentCell {
    
    @objc private func onSingleTap(_ tap: UITapGestureRecognizer) {
        singleTapped()
    }
    
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
            let (frame, scale) = calculatePanResult(pan)
            imageView.frame = frame
            // 通知代理，发生了缩放。代理可依scale值改变背景蒙板alpha值
            panScale(scale)
        case .ended, .cancelled:
            let (frame, _) = calculatePanResult(pan)
            imageView.frame = frame
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
    
    private func calculatePanResult(_ pan: UIPanGestureRecognizer) -> (CGRect, CGFloat) {
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
        // 如果图片当前显示的size小于原size，则重置为原size
        let size = fitSize
        let needResetSize = imageView.bounds.size.width < size.width
            || imageView.bounds.size.height < size.height
        UIView.animate(withDuration: 0.25) {
            self.imageView.center = self.centerOfContentSize
            if needResetSize {
                self.imageView.bounds.size = size
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PreviewAssetContentCell: UIGestureRecognizerDelegate {
    
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
