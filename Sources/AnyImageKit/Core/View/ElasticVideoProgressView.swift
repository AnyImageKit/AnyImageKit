//
//  ElasticVideoProgressView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/11.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

final public class ElasticVideoProgressView: UIControl {
    // MARK: - Public Properties
    
    /// 当前进度值，范围 0.0 到 1.0
    public var value: CGFloat = 0 {
        didSet {
            value = min(max(value, 0), 1)
            updateLayers(animated: false)
        }
    }
    
    /// 进度值变化时的回调
    public var onValueChanged: ((CGFloat) -> Void)?
    /// 结束拖动时的回调
    public var onDragEnd: ((CGFloat) -> Void)?
    /// 开始拖动时的回调
    public var onPanBegan: (() -> Void)?
    
    // MARK: - Public Configuration
    
    /// 轨道高度
    public var trackHeight: CGFloat = 8
    /// 正常状态下的垂直缩放比例
    public var normalScale: CGFloat = 1.0
    /// 拖动状态下的垂直缩放比例
    public var expandedScale: CGFloat = 1.6
    /// 拖动到边缘时的最大弹性偏移量
    public var maxElasticOffset: CGFloat = 10
    
    /// 轨道的背景颜色
    public var trackColor: UIColor = .systemGray5 {
        didSet {
            trackLayer.backgroundColor = trackColor.cgColor
        }
    }
    
    /// 进度条的颜色
    public var progressColor: UIColor = .systemBlue {
        didSet {
            progressLayer.backgroundColor = progressColor.cgColor
        }
    }
    
    // MARK: - Private Properties
    
    private let trackLayer = CALayer()
    private let progressLayer = CALayer()
    
    private var isDragging = false
    private var panStartValue: CGFloat = 0
    private var panStartLocation: CGFloat = 0
    private var elasticOffset: CGFloat = 0
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        clipsToBounds = false
        
        // Track Layer
        trackLayer.backgroundColor = trackColor.cgColor
        trackLayer.masksToBounds = true
        trackLayer.cornerRadius = trackHeight / 2
        trackLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        layer.addSublayer(trackLayer)
        
        // Progress Layer
        progressLayer.backgroundColor = progressColor.cgColor
        progressLayer.cornerRadius = 0 // 保持为0，以便在轨道内部填充
        progressLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        trackLayer.addSublayer(progressLayer)
        
        // Gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers(animated: false)
    }
    
    private func updateLayers(animated: Bool) {
        if value.isNaN || value.isInfinite {
            return
        }
        let width = bounds.width
        let height = bounds.height
        let trackY = height / 2
        
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        
        // Track Layer
        trackLayer.position = CGPoint(x: elasticOffset, y: trackY)
        trackLayer.bounds = CGRect(x: 0, y: 0, width: width - abs(elasticOffset), height: trackHeight)
        
        // Progress Layer
        let progressWidth = (width - abs(elasticOffset)) * value
        progressLayer.position = CGPoint(x: 0, y: trackHeight / 2)
        progressLayer.bounds = CGRect(x: 0, y: 0, width: progressWidth, height: trackHeight)
        
        CATransaction.commit()
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let newValue = min(max(location.x / bounds.width, 0), 1)
        value = newValue
        onValueChanged?(newValue)
        sendActions(for: .valueChanged)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            isDragging = true
            panStartLocation = location.x
            panStartValue = value
            animateScale(expandedScale)
            onPanBegan?()
            
        case .changed:
            let delta = location.x - panStartLocation
            let relative = delta / bounds.width
            var newValue = panStartValue + relative
            var offset: CGFloat = 0
            
            if newValue < 0 {
                offset = max(newValue, -1) * maxElasticOffset
                newValue = 0
            } else if newValue > 1 {
                offset = min(newValue - 1, 1) * maxElasticOffset
                newValue = 1
            }
            
            value = newValue
            elasticOffset = offset
            updateLayers(animated: false)
            
            onValueChanged?(value)
            sendActions(for: .valueChanged)
            
        case .ended, .cancelled, .failed:
            isDragging = false
            animateScale(normalScale)
            animateElasticReturn()
            
            onDragEnd?(value)
            sendActions(for: .valueChanged)
            
        default:
            break
        }
    }
    
    // MARK: - Animations
    
    private func animateScale(_ scale: CGFloat) {
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale.y")
        scaleAnim.fromValue = trackLayer.transform.m22
        scaleAnim.toValue = scale
        scaleAnim.duration = 0.2
        scaleAnim.fillMode = .forwards
        scaleAnim.isRemovedOnCompletion = false
        
        let cornerAnim = CABasicAnimation(keyPath: "cornerRadius")
        cornerAnim.fromValue = trackLayer.cornerRadius
        cornerAnim.toValue = (trackHeight * scale) / 2
        cornerAnim.duration = 0.2
        cornerAnim.fillMode = .forwards
        cornerAnim.isRemovedOnCompletion = false
        
        trackLayer.add(scaleAnim, forKey: "scaleY")
        trackLayer.add(cornerAnim, forKey: "cornerRadius")
        progressLayer.add(scaleAnim, forKey: "scaleY")
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.trackLayer.transform = CATransform3DMakeScale(1, scale, 1)
            self.trackLayer.cornerRadius = (self.trackHeight * scale) / 2
            self.progressLayer.transform = CATransform3DMakeScale(1, scale, 1)
            self.progressLayer.bounds = CGRect(
                x: 0,
                y: 0,
                width: self.progressLayer.bounds.width,
                height: self.trackHeight * scale
            )
        }
        CATransaction.commit()
    }
    
    private func animateElasticReturn() {
        let anim = CASpringAnimation(keyPath: "position.x")
        anim.fromValue = trackLayer.position.x
        anim.toValue = 0
        anim.damping = 8
        anim.initialVelocity = 0
        anim.mass = 1
        anim.stiffness = 120
        anim.duration = anim.settlingDuration
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.elasticOffset = 0
            self.updateLayers(animated: false)
        }
        
        trackLayer.add(anim, forKey: "elastic")
        CATransaction.commit()
    }
}
