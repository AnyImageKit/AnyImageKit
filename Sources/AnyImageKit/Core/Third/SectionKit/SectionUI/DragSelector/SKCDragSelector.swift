//
//  SKCDragSelector.swift
//  Test
//
//  Created by linhey on 8/29/25.
//

import UIKit

@MainActor
public class SKCDragSelector: NSObject {
    
    public struct Configuration {
        /// 启动多选需要的最小移动距离
        public var minimumDistance: CGFloat = 10
        
        /// 高速移动的速度阈值，超过此值优先识别为滚动
        public var highSpeedThreshold: CGFloat = 3000
        
        /// 高速移动时垂直分量的最小值
        public var highSpeedVerticalThreshold: CGFloat = 2000
        
        /// 快速滑动的速度阈值
        public var fastScrollSpeedThreshold: CGFloat = 400
        
        /// 慢速移动的速度阈值，低于此值识别为精确选择
        public var slowMovementThreshold: CGFloat = 300
        
        /// 横向移动距离阈值
        public var horizontalDistanceThreshold: CGFloat = 20
        
        /// 方向主导性的倍数，用于判断是否为某个方向的主导移动
        public var directionDominanceRatio: CGFloat = 1.2
        
        /// 横向移动相对于垂直移动的最小比例
        public var horizontalToVerticalRatio: CGFloat = 0.8
    }

    public var configuration = Configuration()
    private weak var collectionView: UICollectionView?
    private lazy var gesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        gesture.delegate = self
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        // 设置较高的优先级，但不会立即取消其他手势
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    private var multiSelectionManager: SKCRectSelectionManager?
    private var autoScrollManager: SKAutoScrollManager?

    public func reset() {
        autoScrollManager?.stop()
        autoScrollManager = nil
        multiSelectionManager?.endSelection()
        multiSelectionManager = nil
        collectionView?.removeGestureRecognizer(gesture)
        collectionView = nil
    }
    
    public func setup(collectionView: UICollectionView, rectSelectionDelegate: SKCRectSelectionDelegate) {
        reset()
        
        autoScrollManager = SKAutoScrollManager(scrollView: collectionView)
        autoScrollManager?.delegate = self
        
        multiSelectionManager = SKCRectSelectionManager(collectionView: collectionView)
        multiSelectionManager?.delegate = rectSelectionDelegate
        
        self.collectionView = collectionView
        collectionView.addGestureRecognizer(gesture)
        debugPrint("已添加手势识别器到 CollectionView")
        debugPrint("手势识别器数量: \(collectionView.gestureRecognizers?.count ?? 0)")
    }
    
    // MARK: - Debug Helpers
    private func debugPrint(_ message: String) {
        #if DEBUG
        print("[skc-drag]", message)
        #endif
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let collectionView, let multiSelectionManager else {
            return
        }
        let location = gesture.location(in: collectionView)
        let translation = gesture.translation(in: collectionView)
        let velocity = gesture.velocity(in: collectionView)
        
        #if DEBUG
        debugPrint("手势状态: \(gesture.state.rawValue), 位置: \(location), CollectionView bounds: \(collectionView.bounds)")
        #endif
        
        switch gesture.state {
        case .began:
            debugPrint("手势开始 - 位置: \(location)")
            // 先不立即开始多选，等待用户意图明确
            break
            
        case .changed:
            // 检查移动距离，如果移动距离足够大，开始多选
            let distance = sqrt(translation.x * translation.x + translation.y * translation.y)
            
            if !multiSelectionManager.isSelectionActive, distance > configuration.minimumDistance {
                // 检查移动模式 - 区分滚动和多选意图
                let shouldStartSelection = shouldStartMultiSelection(velocity: velocity, translation: translation)
                
                // 调试信息（实际发布时可移除）
                #if DEBUG
                let velocityMagnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
                debugPrint("手势分析 - 速度: \(Int(velocityMagnitude)), 方向: (\(Int(velocity.x)), \(Int(velocity.y))), 启动多选: \(shouldStartSelection)")
                #endif
                
                if shouldStartSelection {
                    startMultiSelection(at: gesture.location(in: collectionView))
                }
            }
            
            if multiSelectionManager.isSelectionActive {
                updateMultiSelection(to: location)
            }
            
        case .ended, .cancelled, .failed:
            debugPrint("手势结束 - 状态: \(gesture.state)")
            if multiSelectionManager.isSelectionActive {
                endMultiSelection()
            }
        default:
            break
        }
    }
    
    private func shouldStartMultiSelection(velocity: CGPoint, translation: CGPoint) -> Bool {
        let velocityMagnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        let absVelocityX = abs(velocity.x)
        let absVelocityY = abs(velocity.y)
        let absTranslationX = abs(translation.x)

        // 检查移动方向和速度特征
        let isHorizontalDominant = absVelocityX > absVelocityY * configuration.directionDominanceRatio
        let isVerticalDominant = absVelocityY > absVelocityX * configuration.directionDominanceRatio
        
        debugPrint("移动分析 - 速度: \(Int(velocityMagnitude)), 方向: (\(Int(velocity.x)), \(Int(velocity.y)))")
        
        // 优先级1: 高速移动且有明显垂直分量 -> 滚动意图
        // 如果总速度很快，且垂直分量足够大，优先认为是滚动
        if velocityMagnitude > configuration.highSpeedThreshold && absVelocityY > configuration.highSpeedVerticalThreshold {
            debugPrint("高速移动且垂直分量显著，识别为滚动意图 (速度: \(Int(velocityMagnitude)))")
            return false
        }
        
        // 优先级2: 垂直方向快速滑动 -> 滚动意图
        // 更严格的垂直滚动检测：垂直速度显著大于横向且总速度较快
        if isVerticalDominant && velocityMagnitude > configuration.fastScrollSpeedThreshold && absVelocityY > absVelocityX * configuration.directionDominanceRatio {
            debugPrint("垂直方向快速滑动，识别为滚动意图 (速度: \(Int(velocityMagnitude)))")
            return false
        }
        
        // 优先级3: 快速横向移动但排除高速滚动 -> 多选意图
        if isHorizontalDominant && velocityMagnitude <= configuration.highSpeedThreshold {
            debugPrint("快速横向移动，识别为多选意图")
            return true
        }
        
        // 优先级4: 慢速垂直移动 -> 多选意图（精确选择）
        if isVerticalDominant && velocityMagnitude <= configuration.fastScrollSpeedThreshold {
            debugPrint("慢速垂直移动，识别为多选意图")
            return true
        }
        
        // 优先级5: 横向移动距离较大 -> 多选意图
        // 只有当横向移动明显大于垂直移动时，才认为是真正的横向移动意图
        let absTranslationY = abs(translation.y)
        if absTranslationX > configuration.horizontalDistanceThreshold && absTranslationX > absTranslationY * configuration.horizontalToVerticalRatio {
            debugPrint("横向移动距离较大且方向明确，识别为多选意图")
            return true
        }
        
        // 优先级6: 整体很慢的移动 -> 多选意图（精确选择）
        if velocityMagnitude < configuration.slowMovementThreshold {
            debugPrint("整体移动很慢，识别为多选意图")
            return true
        }
        
        debugPrint("无法确定意图，默认不启动多选")
        return false
    }
    
    func startMultiSelection(at point: CGPoint) {
        // 禁用 CollectionView 的滚动
        collectionView?.isScrollEnabled = false
        autoScrollManager?.start()
        multiSelectionManager?.beginSelection(at: point)
    }
    
    func updateMultiSelection(to point: CGPoint) {
        // 打印详细的调试信息
        debugPrint("更新多选到位置: \(point)")
        debugPrint("CollectionView bounds: \(collectionView?.bounds ?? .zero)")
        
        // 计算并显示触发区域
        let edgeInset = autoScrollManager?.configuration.edgeInset ?? .zero
        guard let bounds = collectionView?.bounds else {
            return
        }
        let topTriggerArea = CGRect(x: 0, y: 0, width: bounds.width, height: edgeInset)
        let bottomTriggerArea = CGRect(x: 0, y: bounds.height - edgeInset, width: bounds.width, height: edgeInset)
        
        debugPrint("顶部触发区域: \(topTriggerArea)")
        debugPrint("底部触发区域: \(bottomTriggerArea)")
        debugPrint("点是否在顶部触发区域: \(topTriggerArea.contains(point))")
        debugPrint("点是否在底部触发区域: \(bottomTriggerArea.contains(point))")
        
        autoScrollManager?.updateAutoScroll(for: point)
        multiSelectionManager?.updateSelection(to: point)
    }
    
    func endMultiSelection() {
        // 恢复 CollectionView 的滚动
        collectionView?.isScrollEnabled = true
        autoScrollManager?.stop()
        multiSelectionManager?.endSelection()
    }

}

// MARK: - UIGestureRecognizerDelegate
extension SKCDragSelector: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果正在进行多选，不允许与其他手势同时识别（包括滚动手势）
        if multiSelectionManager?.isSelectionActive == true {
            debugPrint("多选激活中，阻止其他手势")
            return false
        }
        
        // 在没有进行多选时，允许与其他手势同时识别，让系统决定
        debugPrint("允许与其他手势同时识别: \(type(of: otherGestureRecognizer))")
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let collectionView = collectionView else {
            return false
        }
        // 确保触摸是在集合视图的内容区域内
        let location = touch.location(in: collectionView)
        let collectionBounds = collectionView.bounds
        
        debugPrint("触摸检查 - 位置: \(location), bounds: \(collectionBounds)")
        
        // 扩大有效区域，包含边缘
        let expandedBounds = collectionBounds.insetBy(dx: -5, dy: -5)
        let isInBounds = expandedBounds.contains(location)
        
        debugPrint("触摸是否在有效区域: \(isInBounds)")
        return isInBounds
    }
    
    private func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBegin gesture: UIGestureRecognizer) -> Bool {
        let location = gesture.location(in: collectionView)
        debugPrint("手势开始检查 - 位置: \(location)")
        return true
    }
}

// MARK: - AutoScrollManagerDelegate
extension SKCDragSelector: SKAutoScrollManagerDelegate {
    
    public func autoScrollManager(_ manager: SKAutoScrollManager, didScrollToPoint point: CGPoint) {
        multiSelectionManager?.updateSelection(to: point)
    }
    
}
