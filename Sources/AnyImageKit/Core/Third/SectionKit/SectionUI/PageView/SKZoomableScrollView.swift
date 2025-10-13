//
//  SKZoomableScrollView.swift
//  UIComponents
//
//  Created by linhey on 5/10/25.
//

import UIKit
import Combine
import SwiftUI

public class SKZoomableContext {
    @Published public var size: CGSize = .zero
    @Published public var zoomScale: CGFloat = 1
    @Published public var doubleTapAction: ((_ gesture: UITapGestureRecognizer) -> Void)?
    @Published public var longPressAction: ((_ gesture: UILongPressGestureRecognizer) -> Void)?
    @Published public var singleTapAction: ((_ gesture: UITapGestureRecognizer) -> Void)?
    public init() {}
}

public protocol SKZoomableContentView {
    var zoomableContext: SKZoomableContext { get }
}

public extension SKZoomableContentView where Self: UIView {
    
    func wrapperToZoomableView() -> SKZoomableScrollView {
        let view = SKZoomableScrollView()
        view.config(self, context: zoomableContext)
        return view
    }
    
}

public class SKZoomableScrollView: UIView, UIGestureRecognizerDelegate {
    
    private class PlaceholderContentView: UIView, SKZoomableContentView {
        var zoomableContext: SKZoomableContext = .init()
    }
    
    public struct PanToDismiss {
        
        let alphaSubject = CurrentValueSubject<CGFloat, Never>(1)
        public var dismiss: () -> Void
        public var alphaPublisher: AnyPublisher<CGFloat, Never> { alphaSubject.eraseToAnyPublisher() }
        public var alpha: (_ value: CGFloat) -> Void
        public weak var container: UIView?
        
        public init(container: UIView? = nil,
                    dismiss: @escaping () -> Void,
                    alpha: @escaping (_: CGFloat) -> Void) {
            self.container = container
            self.dismiss = dismiss
            self.alpha = alpha
        }
    }
    
    private var scrollDirection: Axis = .horizontal
    public private(set) var contentView: UIView = PlaceholderContentView()
    private var context: SKZoomableContext = .init()
    private var cancellables = Set<AnyCancellable>()
    public private(set) lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.maximumZoomScale = maximumZoomScale
        view.minimumZoomScale = minimumZoomScale
        view.zoomScale = 1
        view.bouncesZoom = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()

    public private(set) lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        gesture.minimumPressDuration = 0.5
        return gesture
    }()
    
    public private(set) lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    public private(set) lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.require(toFail: doubleTapGesture)
        return gesture
    }()
    
    public var minimumZoomScale: CGFloat = 1 {
        didSet { scrollView.minimumZoomScale = minimumZoomScale }
    }
    
    public var maximumZoomScale: CGFloat = 5 {
        didSet { scrollView.maximumZoomScale = maximumZoomScale }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(scrollView)
        addGestureRecognizer(doubleTapGesture)
        addGestureRecognizer(longPressGesture)
        addGestureRecognizer(singleTapGesture)
    }
    
    /// 配置要缩放的内容视图
    public func config(_ content: UIView, context: SKZoomableContext) {
        cancellables.removeAll()
        contentView.removeFromSuperview()
        content.removeFromSuperview()
        scrollView.addSubview(content)
        
        context.$singleTapAction.sink { [weak self] block in
            guard let self = self else { return }
            singleTapGesture.isEnabled = block != nil
        }.store(in: &cancellables)
        
        context.$longPressAction.sink { [weak self] block in
            guard let self = self else { return }
            longPressGesture.isEnabled = block != nil
        }.store(in: &cancellables)
        
        context.$size.removeDuplicates().sink { [weak self] size in
            guard let self = self else { return }
            layoutSubviews()
        }.store(in: &cancellables)
        
        contentView = content
        self.context = context
        layoutSubviews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        scrollView.setZoomScale(1.0, animated: false)
        let size = computeImageLayoutSize(for: context.size, in: scrollView)
        let origin = computeImageLayoutOrigin(for: size, in: scrollView)
        contentView.frame = CGRect(origin: origin, size: size)
        scrollView.setZoomScale(1.0, animated: false)
        context.zoomScale = scrollView.zoomScale
    }
    
    open func computeImageLayoutSize(for contentSize: CGSize, in scrollView: UIScrollView) -> CGSize {
        guard contentSize.width > 0, contentSize.height > 0 else { return .zero }
        var width: CGFloat
        var height: CGFloat
        let containerSize = scrollView.bounds.size
        if scrollDirection == .horizontal {
            // 横竖屏判断
            if containerSize.width < containerSize.height {
                width = containerSize.width
                height = contentSize.height / contentSize.width * width
            } else {
                height = containerSize.height
                width = contentSize.width / contentSize.height * height
                if width > containerSize.width {
                    width = containerSize.width
                    height = contentSize.height / contentSize.width * width
                }
            }
        } else {
            width = containerSize.width
            height = contentSize.height / contentSize.width * width
            if height > containerSize.height {
                height = containerSize.height
                width = contentSize.width / contentSize.height * height
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    open func computeImageLayoutOrigin(for imageSize: CGSize, in scrollView: UIScrollView) -> CGPoint {
        let containerSize = scrollView.bounds.size
        var y = (containerSize.height - imageSize.height) * 0.5
        y = max(0, y)
        var x = (containerSize.width - imageSize.width) * 0.5
        x = max(0, x)
        return CGPoint(x: x, y: y)
    }
    
    open func computeImageLayoutCenter(in scrollView: UIScrollView) -> CGPoint {
        var x = scrollView.contentSize.width * 0.5
        var y = scrollView.contentSize.height * 0.5
        let offsetX = (bounds.width - scrollView.contentSize.width) * 0.5
        if offsetX > 0 {
            x += offsetX
        }
        let offsetY = (bounds.height - scrollView.contentSize.height) * 0.5
        if offsetY > 0 {
            y += offsetY
        }
        return CGPoint(x: x, y: y)
    }
        
    private var beganFrame = CGRect.zero
    private var beganTouch = CGPoint.zero
    private var panToDismiss: PanToDismiss?
    private weak var existedPan: UIPanGestureRecognizer?

    /// 添加拖动手势
    open func panToDismiss(_ value: PanToDismiss) {
        existedPan?.removeTarget(self, action: #selector(onPan(_:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        (value.container ?? self).addGestureRecognizer(pan)
        existedPan = pan
        self.panToDismiss = value
    }
    
    /// 响应拖动
    @objc open func onPan(_ pan: UIPanGestureRecognizer) {
        guard let panToDismiss, context.size != .zero else {
            return
        }
        switch pan.state {
        case .began:
            beganFrame = contentView.frame
            beganTouch = pan.location(in: scrollView)
        case .changed:
            let result = panResult(pan)
            contentView.frame = result.frame
            panToDismiss.alpha(result.scale * result.scale)
            panToDismiss.alphaSubject.send(result.scale * result.scale)
        case .ended, .cancelled:
            contentView.frame = panResult(pan).frame
            let isDown = pan.velocity(in: self).y > 0
            if isDown {
                panToDismiss.dismiss()
            } else {
                panToDismiss.alpha(1)
                panToDismiss.alphaSubject.send(1)
                resetImageViewPosition()
            }
        default:
            resetImageViewPosition()
        }
    }
    
    /// 计算拖动时图片应调整的frame和scale值
    private func panResult(_ pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
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
    
    /// 复位ImageView
    private func resetImageViewPosition() {
        // 如果图片当前显示的size小于原size，则重置为原size
        let size = computeImageLayoutSize(for: context.size, in: scrollView)
        let needResetSize = contentView.bounds.size.width < size.width || contentView.bounds.size.height < size.height
        UIView.animate(withDuration: 0.25) {
            self.contentView.center = self.computeImageLayoutCenter(in: self.scrollView)
            if needResetSize {
                self.contentView.bounds.size = size
            }
        }
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只处理pan手势
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

extension SKZoomableScrollView {
    
    @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        context.singleTapAction?(gesture)
    }

    @objc private func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        context.longPressAction?(gesture)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if let block = context.doubleTapAction {
            block(gesture)
        } else if scrollView.zoomScale < 1.1 {
            // 如果当前没有任何缩放，则放大到目标比例，否则重置到原比例
            // 以点击的位置为中心，放大
            let pointInView = gesture.location(in: contentView)
            let width = scrollView.bounds.size.width / scrollView.maximumZoomScale
            let height = scrollView.bounds.size.height / scrollView.maximumZoomScale
            let x = pointInView.x - (width / 2.0)
            let y = pointInView.y - (height / 2.0)
            scrollView.zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
}

extension SKZoomableScrollView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        contentView.center = computeImageLayoutCenter(in: scrollView)
        context.zoomScale = scrollView.zoomScale
    }
    
}
