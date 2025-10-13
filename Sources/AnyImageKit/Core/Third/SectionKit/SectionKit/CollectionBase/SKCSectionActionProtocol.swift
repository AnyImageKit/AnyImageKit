//
//  File.swift
//
//
//  Created by linhey on 2022/8/11.
//

#if canImport(UIKit)
import UIKit

public protocol SKCSectionActionProtocol: AnyObject {
    
    var itemCount: Int { get }
    var sectionInjection: SKCSectionInjection? { get set }
    func config(sectionView: UICollectionView)
    
}

public extension SKCSectionActionProtocol {
    
    var isBindSectionView: Bool { sectionInjection?.sectionView != nil }
    
    var sectionView: UICollectionView {
        guard let view = sectionInjection?.sectionView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        }
        return view
    }
    
    func config(sectionView: UICollectionView) {}
    
}

public extension SKCSectionActionProtocol {
    
    func pick(_ updates: () -> Void, completion: ((_ flag: Bool) -> Void)? = nil) {
        sectionInjection?.pick(updates, completion: completion)
    }
    
    func reload() {
        sectionInjection?.reload()
    }
    
    /// 刷新指定行
    /// - Parameter row: 指定行
    func refresh(at row: Int) {
        refresh(at: [row])
    }
    
    /// 刷新指定行
    /// - Parameter row: 指定行
    func refresh(at row: [Int]) {
        sectionInjection?.reload(cell: row)
    }
    
    /// 移除指定行
    /// - Parameters:
    ///   - row: 指定行
    ///   - before: 移除数据
    func remove(at row: Int, before: (() -> Void)?) {
        remove(at: [row], before: before)
    }
    
    /// 移除指定行
    /// - Parameters:
    ///   - row: 指定行
    ///   - before: 移除数据
    func remove(at row: [Int], before: (() -> Void)?) {
        before?()
        sectionInjection?.delete(cell: row)
    }
    
}

public extension SKCSectionActionProtocol {
    
    /// 获取被选中的 cell 集合
    var indexForSelectedItems: [Int] {
        (sectionInjection?.sectionView?.indexPathsForSelectedItems ?? [])
            .filter { $0.section == sectionInjection?.index }
            .map(\.row)
            .sorted(by: <)
    }
    
    /// 获取可见的 cell 的 row 集合
    var indexsForVisibleItems: [Int] {
        sectionInjection?
            .sectionView?
            .indexPathsForVisibleItems
            .filter { $0.section == sectionInjection?.index }
            .map(\.row)
            .sorted(by: <) ?? []
    }
    
    /// 获取可见的 cell 集合
    var visibleCells: [UICollectionViewCell] {
        let indexs = indexsForVisibleItems
        guard !indexs.isEmpty else {
            return []
        }
        return indexs.compactMap(cellForItem(at:))
    }
    
    /// 获取指定 row 的 Cell
    /// - Parameter row: row
    /// - Returns: cell
    func cellForItem(at row: Int) -> UICollectionViewCell? {
        guard isBindSectionView else { return nil }
       return sectionView.cellForItem(at: indexPath(from: row))
    }
    
    func visibleSupplementaryViews(of kind: SKSupplementaryKind) -> [UICollectionReusableView] {
        sectionInjection?
            .sectionView?
            .visibleSupplementaryViews(ofKind: kind.rawValue) ?? []
    }
    
    func indexsForVisibleSupplementaryViews(of kind: SKSupplementaryKind) -> [Int] {
        sectionInjection?
            .sectionView?
            .indexPathsForVisibleSupplementaryElements(ofKind: kind.rawValue)
            .filter { $0.section == sectionInjection?.index }
            .map(\.row) ?? []
    }
    
}

public extension SKCSectionActionProtocol {
    
    func layoutAttributesForItem(at row: Int) -> UICollectionViewLayoutAttributes? {
        sectionInjection?.sectionView?.collectionViewLayout.layoutAttributesForItem(at: indexPath(from: row))
    }
    
    func layoutAttributesForSupplementaryView(ofKind kind: SKSupplementaryKind, at row: Int) -> UICollectionViewLayoutAttributes? {
        sectionInjection?.sectionView?.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: kind.rawValue, at: indexPath(from: row))
    }
    
    func layoutAttributesForDecorationView(ofKind kind: SKSupplementaryKind, at row: Int) -> UICollectionViewLayoutAttributes? {
        sectionInjection?.sectionView?.collectionViewLayout.layoutAttributesForDecorationView(ofKind: kind.rawValue, at: indexPath(from: row))
    }
    
}

public extension SKCSectionActionProtocol {
    
    /**
     该方法用于根据给定的value返回一个IndexPath对象。如果sectionInjection为nil，则会触发断言失败，并返回一个item为value，section为0的IndexPath对象。否则，返回一个item为value，section为sectionInjection的index的IndexPath对象。
     */
    func indexPath(from value: Int) -> IndexPath {
        guard let injection = sectionInjection else {
            assertionFailure()
            return .init(item: value, section: 0)
        }
        return injection.indexPath(from: value)
    }
    
    func _register<T: UICollectionViewCell & SKLoadViewProtocol>(_ cell: T.Type) {
        _register(cell, id: cell.identifier)
    }
    
    func _register<T: UICollectionViewCell & SKLoadViewProtocol>(_ cell: T.Type, id: String) {
        if let nib = T.nib {
            sectionView.register(nib, forCellWithReuseIdentifier: id)
        } else {
            sectionView.register(T.self, forCellWithReuseIdentifier: id)
        }
    }
    
    func _register<T: UICollectionReusableView & SKLoadViewProtocol>(_ view: T.Type, for kind: SKSupplementaryKind) {
        if let nib = T.nib {
            sectionView.register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        }
    }
    func _dequeue<V: UICollectionViewCell & SKLoadViewProtocol>(at row: Int) -> V {
        _dequeue(at: row, id: V.identifier)
    }
    
    func _dequeue<V: UICollectionViewCell & SKLoadViewProtocol>(at row: Int, id: String) -> V {
        let cell = sectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath(from: row))
        if let cell = cell as? V {
            return cell
        } else {
            fatalError("[SectionKit] cell dequeue failed, \(cell.debugDescription)")
        }
    }
    
    func _dequeue<V: UICollectionReusableView & SKLoadViewProtocol>(kind: SKSupplementaryKind) -> V {
        sectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: V.identifier, for: indexPath(from: 0)) as! V
    }
    
    func register<T: UICollectionViewCell & SKLoadViewProtocol>(_ cell: T.Type) { _register(cell) }
    func register<T: UICollectionReusableView & SKLoadViewProtocol>(_ view: T.Type, for kind: SKSupplementaryKind) { _register(view, for: kind) }
    
    func dequeue<V: UICollectionViewCell & SKLoadViewProtocol>(at row: Int, for type: V.Type) -> V { _dequeue(at: row) as V }
    func dequeue<V: UICollectionViewCell & SKLoadViewProtocol>(at row: Int) -> V { _dequeue(at: row) as V }
    
    func dequeue<V: UICollectionReusableView & SKLoadViewProtocol>(kind: SKSupplementaryKind, for type: V.Type) -> V { _dequeue(kind: kind) as V }
    func dequeue<V: UICollectionReusableView & SKLoadViewProtocol>(kind: SKSupplementaryKind) -> V { _dequeue(kind: kind) as V }
    
}

public extension SKCSectionActionProtocol {
    
    func scrollToTop(animated: Bool) {
        scroll(to: 0, at: .top, animated: animated)
    }
    
    func scrollToBottom(animated: Bool) {
        scroll(to: self.itemCount - 1, at: .bottom, animated: animated)
    }
    
    func scroll(to row: Int?, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard let row = row, let sectionView = sectionInjection?.sectionView else {
            return
        }
        guard row >= 0, row < itemCount else {
            assertionFailure("row 的值应该在 (0..<\(itemCount) 之间")
            return
        }
        sectionView.scrollToItem(at: indexPath(from: row), at: scrollPosition, animated: animated)
    }
    
    @discardableResult
    func scroll(to kind: SKSupplementaryKind,
                at scrollPosition: UICollectionView.ScrollPosition? = nil,
                offset: CGPoint? = nil,
                animated: Bool = true) -> Bool {
        guard let sectionView = sectionInjection?.sectionView,
              sectionView.window != nil,
              sectionView.frame.width > 0,
              sectionView.frame.height > 0 else {
            return false
        }
        
        var attributes: UICollectionViewLayoutAttributes?
        
        switch kind {
        case .header, .footer, .custom:
            attributes = sectionView.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: kind.rawValue, at: indexPath(from: 0))
        case .cell:
            attributes = sectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath(from: 0))
        }
            
        guard let attributes, attributes.frame != .zero else {
            return false
        }
            
        scrollWithOffset(sectionView: sectionView,
                         position: scrollPosition ?? defaultPosition(),
                         frame: attributes.frame,
                         offset: offset ?? .zero,
                         animated: animated)
        return true
    }
    
    @discardableResult
    func scroll(to row: Int,
                at scrollPosition: UICollectionView.ScrollPosition? = nil,
                offset: CGPoint? = nil,
                animated: Bool = true) -> Bool {
        guard let sectionView = sectionInjection?.sectionView,
              sectionView.window != nil,
              sectionView.frame.width > 0,
              sectionView.frame.height > 0,
              let indexPath = sectionInjection?.indexPath(from: row),
              let attributes = sectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
            return false
        }
        
        let position = scrollPosition ?? defaultPosition()
        let frame = attributes.frame
        
        if let offset {
            if frame == .zero {
                return false
            }
            scrollWithOffset(sectionView: sectionView,
                             position: position,
                             frame: frame,
                             offset: offset,
                             animated: animated)
        } else {
            let isPagingEnabled: Bool?
            if sectionView.isPagingEnabled {
                isPagingEnabled = sectionView.isPagingEnabled
                sectionView.isPagingEnabled = false
            } else {
                isPagingEnabled = nil
            }
            sectionView.scrollToItem(at: indexPath, at: position, animated: animated)
            if let isPagingEnabled {
                sectionView.isPagingEnabled = isPagingEnabled
            }
        }
        return true
    }
    
    private func defaultPosition() -> UICollectionView.ScrollPosition {
        if let direction = (sectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection {
            switch direction {
            case .horizontal:
                return .left
            case .vertical:
                return .top
            @unknown default:
                return .top
            }
        } else {
            return .top
        }
    }
    
    private func scrollWithOffset(sectionView: UICollectionView,
                                  position: UICollectionView.ScrollPosition,
                                  frame: CGRect,
                                  offset: CGPoint,
                                  animated: Bool) {
        let point: CGPoint
        switch position {
        case .top:
            // 将该 item 的上边缘与 collectionView 的顶部对齐
            point = CGPoint(x: sectionView.contentOffset.x, y: frame.minY)
        case .bottom:
            // 将该 item 的下边缘与 collectionView 的底部对齐
            // 这里需要考虑当前 collectionView 的可见区域高度，故用 frame.maxY - sectionView.bounds.height
            point = CGPoint(x: sectionView.contentOffset.x, y: frame.maxY - sectionView.bounds.height)
        case .centeredVertically:
            // 垂直居中显示 item：item 的中点居中于 collectionView 的中点
            let offsetY = frame.midY - (sectionView.bounds.height / 2)
            point = CGPoint(x: frame.minX, y: max(offsetY, 0)) // 避免滚动到负值位置
        case .left:
            // 将该 item 的左边缘与 collectionView 左侧对齐
            point = CGPoint(x: frame.minX, y: frame.minY)
        case .right:
            // 将该 item 的右边缘与 collectionView 右侧对齐
            let offsetX = frame.maxX - sectionView.bounds.width
            point = CGPoint(x: max(offsetX, 0), y: frame.minY) // 避免出现负值
        case .centeredHorizontally:
            // 水平居中显示 item：item 的中点居中于 collectionView 的中点
            let offsetX = frame.midX - (sectionView.bounds.width / 2)
            point = CGPoint(x: max(offsetX, 0), y: frame.minY)
        default:
            // 将该 item 的上边缘与 collectionView 的顶部对齐
            point = CGPoint(x: frame.minX, y: frame.minY)
        }
        
        if position == .top || position == .bottom {
            let maxOffsetY = sectionView.contentSize.height - sectionView.bounds.height + sectionView.adjustedContentInset.bottom
            let trueOffsetY = min(max(maxOffsetY, offset.y), point.y + offset.y)
            let offset = CGPoint(x: point.x + offset.x, y: trueOffsetY)
            sectionView.setContentOffset(offset, animated: animated)
        } else {
            sectionView.setContentOffset(.init(x: point.x + offset.x, y: point.y + offset.y), animated: animated)
        }
    }
}
#endif
