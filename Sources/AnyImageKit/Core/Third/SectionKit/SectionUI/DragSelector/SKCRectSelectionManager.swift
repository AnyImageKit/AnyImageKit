//
//  MultiSelectionManagerDelegate.swift
//  Test
//
//  Created by linhey on 8/29/25.
//

import UIKit

// MARK: - 多选管理器
@MainActor
public protocol SKCRectSelectionDelegate: AnyObject {
    func rectSelectionManager(_ manager: SKCRectSelectionManager, didUpdateSelection isSelected: Bool, for indexPath: IndexPath)
    func rectSelectionManager(_ manager: SKCRectSelectionManager, isSelectedAt indexPath: IndexPath) -> Bool
    func rectSelectionManager(_ manager: SKCRectSelectionManager, willDisplay overlayView: SKSelectionOverlayView)
}

@MainActor
public class SKCRectSelectionManager {
    
    weak var delegate: SKCRectSelectionDelegate?
    private weak var collectionView: UICollectionView?
    private var selectionStartPoint: CGPoint?
    private var selectionOverlay: SKSelectionOverlayView?
    private var initialSelectionMode: InitialSelectionMode?
    private var cellsOriginalStates: [IndexPath: Bool] = [:]
    private var previousSelectedIndexPaths: Set<IndexPath> = []
    
    // 添加选择状态标识
    var isSelectionActive: Bool {
        return selectionStartPoint != nil && selectionOverlay != nil
    }
    
    private enum InitialSelectionMode {
        case selecting   // 选中模式
        case deselecting // 取消选中模式
    }
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func beginSelection(at point: CGPoint) {
        guard let collectionView = collectionView else { return }
        
        selectionStartPoint = point
        cellsOriginalStates = [:]
        
        // 创建选择覆盖层
        let overlay = SKSelectionOverlayView()
        delegate?.rectSelectionManager(self, willDisplay: overlay)
        collectionView.addSubview(overlay)
        self.selectionOverlay = overlay
        
        // 确定初始选择模式
        if let indexPath = collectionView.indexPathForItem(at: point),
           let isSelected = delegate?.rectSelectionManager(self, isSelectedAt: indexPath) {
            initialSelectionMode = isSelected ? .deselecting : .selecting
        } else {
            // 在空白区域开始拖拽，默认为选择模式
            initialSelectionMode = .selecting
        }
        
        // 初始显示一个小的选择区域
        let initialRect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        selectionOverlay?.updateSelectionRect(initialRect)
    }
    
    func updateSelection(to point: CGPoint) {
        guard let startPoint = selectionStartPoint,
              let overlay = selectionOverlay else { return }
        
        print("更新选择区域 - 起始点: \(startPoint), 当前点: \(point)")
        
        // 更新选择矩形
        let selectionRect = CGRect(
            x: min(startPoint.x, point.x),
            y: min(startPoint.y, point.y),
            width: abs(point.x - startPoint.x),
            height: abs(point.y - startPoint.y)
        )
        
        print("选择矩形: \(selectionRect)")
        
        overlay.updateSelectionRect(selectionRect)
        
        // 更新选中状态
        updateCellsSelection(in: selectionRect)
    }
    
    func endSelection() {
        selectionOverlay?.removeFromSuperview()
        selectionOverlay = nil
        selectionStartPoint = nil
        initialSelectionMode = nil
        cellsOriginalStates.removeAll()
        previousSelectedIndexPaths.removeAll()
    }
    
    private func updateCellsSelection(in rect: CGRect) {
        guard let collectionView = collectionView else { return }
        
        let attributes = collectionView.collectionViewLayout.layoutAttributesForElements(in: rect) ?? []
        let currentIndexPathsInRect = Set(attributes.map(\.indexPath))
        
        print("当前选择区域内的 cells: \(currentIndexPathsInRect)")
        
        // 只有当选择区域发生变化时才处理
        guard currentIndexPathsInRect != previousSelectedIndexPaths else { return }
        
        // 记录新 cells 的原始状态
        for indexPath in currentIndexPathsInRect {
            if cellsOriginalStates[indexPath] == nil {
                let isSelected = delegate?.rectSelectionManager(self, isSelectedAt: indexPath) ?? false
                cellsOriginalStates[indexPath] = isSelected
            }
        }

        // 确定目标状态 - 使用 lazy 延迟计算
        let targetSelectionState: Bool = {
            if let firstIndexPath = currentIndexPathsInRect.first,
               let firstCellOriginalState = cellsOriginalStates[firstIndexPath] {
                return !firstCellOriginalState
            } else {
                return initialSelectionMode == .selecting
            }
        }()

        // 更新当前 rect 内的 cells
        currentIndexPathsInRect.forEach { indexPath in
            delegate?.rectSelectionManager(self, didUpdateSelection: targetSelectionState, for: indexPath)
        }

        // 恢复之前在 rect 内但现在不在的 cells
        let cellsToRestore = previousSelectedIndexPaths.subtracting(currentIndexPathsInRect)
        cellsToRestore.forEach { indexPath in
            if let originalState = cellsOriginalStates[indexPath] {
                delegate?.rectSelectionManager(self, didUpdateSelection: originalState, for: indexPath)
            }
        }
        
        // 更新记录
        previousSelectedIndexPaths = currentIndexPathsInRect
    }
}
