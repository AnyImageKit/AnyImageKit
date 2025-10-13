//
//  AutoScrollManagerDelegate.swift
//  Test
//
//  Created by linhey on 8/29/25.
//

import UIKit

// MARK: - 自动滚动管理器
public protocol SKAutoScrollManagerDelegate: AnyObject {
    func autoScrollManager(_ manager: SKAutoScrollManager, didScrollToPoint point: CGPoint)
}

public class SKAutoScrollManager {
    
    public struct Configuration {
         // 减小边缘触发区域，适应安全区域
        public let edgeInset: CGFloat
         // 稍微减慢滚动速度，提高精确度
        public let maxSpeed: CGFloat
        // 高帧率兼容性：目标帧率(建议60fps以保证一致体验)
        public let targetFPS: Int
        
        public init(edgeInset: CGFloat = 40, maxSpeed: CGFloat = 12, targetFPS: Int = 60) {
             self.edgeInset = edgeInset
             self.maxSpeed = maxSpeed
             self.targetFPS = targetFPS
         }
     }
    
    weak var delegate: SKAutoScrollManagerDelegate?
    public var configuration = Configuration()
    private weak var scrollView: UIScrollView?
    private var displayLink: CADisplayLink?
    private var scrollVelocity: CGVector = .zero
    private var currentTouchPoint: CGPoint?
    
    // 高帧率兼容性相关属性
    private var lastUpdateTime: CFTimeInterval = 0
    private var frameInterval: CFTimeInterval {
        return 1.0 / Double(configuration.targetFPS)
    }
    
    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    public func start() {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(performAutoScroll))
        
        // 统一的高帧率兼容性设置
        configureFrameRate()
        
        displayLink?.add(to: .main, forMode: .common)
        lastUpdateTime = 0 // 重置计时器
        // 自动滚动已启动，使用配置的目标帧率
    }
    
    // 提取帧率配置逻辑
    private func configureFrameRate() {
        if #available(iOS 15.0, *) {
            // iOS 15+ 支持直接设置期望帧率
            displayLink?.preferredFrameRateRange = CAFrameRateRange(
                minimum: Float(configuration.targetFPS),
                maximum: Float(configuration.targetFPS),
                preferred: Float(configuration.targetFPS)
            )
        } else {
            // iOS 15 以下使用 preferredFramesPerSecond
            displayLink?.preferredFramesPerSecond = configuration.targetFPS
        }
    }
    
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
        scrollVelocity = .zero
        currentTouchPoint = nil
        // 自动滚动已停止，清理所有状态
    }
    
    func updateAutoScroll(for point: CGPoint) {
        currentTouchPoint = point
        scrollVelocity = calculateScrollVelocity(for: point)
        // 实时更新滚动速度，基于当前触摸点位置
    }
    
    @objc private func performAutoScroll() {
        guard let scrollView = scrollView, 
              scrollVelocity != .zero,
              let timeScale = calculateTimeScale() else {
            return
        }
        
        // 计算新的偏移量并应用时间修正
        var newOffset = scrollView.contentOffset
        newOffset.x += scrollVelocity.dx * timeScale
        newOffset.y += scrollVelocity.dy * timeScale
        
        // 应用边界限制并更新
        let clampedOffset = clampOffset(newOffset, for: scrollView)
        
        // 只有偏移真正改变时才更新UI
        if !clampedOffset.equalTo(scrollView.contentOffset) {
            scrollView.contentOffset = clampedOffset
            currentTouchPoint.map { delegate?.autoScrollManager(self, didScrollToPoint: $0) }
        }
    }
    
    // 提取时间计算逻辑
    private func calculateTimeScale() -> CGFloat? {
        let currentTime = CACurrentMediaTime()
        
        // 初次运行，建立基准时间
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return nil
        }
        
        let deltaTime = currentTime - lastUpdateTime
        
        // 帧率过高，跳过此帧
        guard deltaTime >= frameInterval else { return nil }
        
        lastUpdateTime = currentTime
        return deltaTime * Double(configuration.targetFPS)
    }
    
    // 提取边界限制逻辑
    private func clampOffset(_ offset: CGPoint, for scrollView: UIScrollView) -> CGPoint {
        let maxX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
        let maxY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
        
        return CGPoint(
            x: max(0, min(offset.x, maxX)),
            y: max(0, min(offset.y, maxY))
        )
    }
    
    private func calculateScrollVelocity(for point: CGPoint) -> CGVector {
        guard let scrollView = scrollView,
              let pointInSuperview = scrollView.superview?.convert(point, from: scrollView) else {
            return .zero
        }
        
        let frame = scrollView.frame
        let bounds = scrollView.bounds
        let edgeInset = configuration.edgeInset
        let maxSpeed = configuration.maxSpeed
        
        // 使用统一的方向计算逻辑
        let velocityX = calculateDirectionalVelocity(
            position: pointInSuperview.x,
            frameStart: frame.minX,
            frameEnd: frame.maxX,
            currentOffset: scrollView.contentOffset.x,
            maxOffset: max(0, scrollView.contentSize.width - bounds.width),
            edgeInset: edgeInset,
            maxSpeed: maxSpeed
        )
        
        let velocityY = calculateDirectionalVelocity(
            position: pointInSuperview.y,
            frameStart: frame.minY,
            frameEnd: frame.maxY,
            currentOffset: scrollView.contentOffset.y,
            maxOffset: max(0, scrollView.contentSize.height - bounds.height),
            edgeInset: edgeInset,
            maxSpeed: maxSpeed
        )
        
        return CGVector(dx: velocityX, dy: velocityY)
    }
    
    // 统一的方向性速度计算逻辑
    private func calculateDirectionalVelocity(
        position: CGFloat,
        frameStart: CGFloat,
        frameEnd: CGFloat,
        currentOffset: CGFloat,
        maxOffset: CGFloat,
        edgeInset: CGFloat,
        maxSpeed: CGFloat
    ) -> CGFloat {
        let startTrigger = frameStart + edgeInset
        let endTrigger = frameEnd - edgeInset
        
        // 检查是否在起始边缘触发区域（向负方向滚动）
        if position <= startTrigger && currentOffset > 0 {
            let distance = max(0, startTrigger - position)
            let ratio = min(1, distance / edgeInset)
            return -maxSpeed * ratio
        }
        
        // 检查是否在结束边缘触发区域（向正方向滚动）
        if position >= endTrigger && currentOffset < maxOffset {
            let distance = max(0, position - endTrigger)
            let ratio = min(1, distance / edgeInset)
            return maxSpeed * ratio
        }
        
        return 0
    }
}
