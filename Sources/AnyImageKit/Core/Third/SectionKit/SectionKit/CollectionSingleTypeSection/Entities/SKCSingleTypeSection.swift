//
//  File.swift
//
//
//  Created by linhey on 2022/8/18.
//

#if canImport(UIKit)
import UIKit
import Combine

open class SKCSingleTypeSection<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: SKCSingleTypeSectionProtocol, SKDisplayedTimesProtocol, SKEnvironmentConfiguration {
    
    public typealias SectionBlock<Return>               = (_ section: SKCSingleTypeSection<Cell>) -> Return
    public typealias ContextBlock<Context, Return>      = (_ context: Context) -> Return
    public typealias AsyncContextBlock<Context, Return> = @MainActor (_ context: Context) async throws -> Return
    
    public typealias CellStyleBox = SKIDBox<UUID, CellStyleBlock>
    
    public typealias LoadedBlock       = SectionBlock<Void>
    public typealias SectionStyleBlock = SectionBlock<Void>
    public typealias CellStyleBlock    = ContextBlock<SKCCellStyleContext<Cell>, Void>
    
    public typealias SectionStyleWeakBlock<T: AnyObject> = (_ self: T, _ section: SKCSingleTypeSection<Cell>) -> Void
    public typealias CellStyleWeakBlock<T: AnyObject>    = (_ self: T, _ context: SKCCellStyleContext<Cell>) -> Void
    public typealias CellActionWeakBlock<T: AnyObject>   = (_ self: T, _ context: CellActionContext) -> Void
    
    public typealias SupplementaryActionBlock = ContextBlock<SupplementaryActionContext, Void>
    public typealias CellActionBlock          = ContextBlock<CellActionContext, Void>
    public typealias ContextMenuBlock         = ContextBlock<ContextMenuContext, SKUIContextMenuResult?>
    public typealias CellShouldBlock          = ContextBlock<ContextMenuContext, Bool?>
    
    public enum LifeCycleKind {
        case loadedToSectionView(UICollectionView)
    }
    
    public enum ReloadKind {
        case normal
        case configAndDelete
        case difference(by: (_ lhs: Model, _ rhs: Model) -> Bool)
        
        public static func difference() -> ReloadKind where Model: Equatable {
            return .difference { lhs, rhs in
                lhs == rhs
            }
        }
        
        public static func difference<ID: Equatable>(by id: KeyPath<Model, ID>) -> ReloadKind where ID: Equatable {
            return .difference { lhs, rhs in
                lhs[keyPath: id] == rhs[keyPath: id]
            }
        }
        
    }
    
    public struct Feature {
        /// 忽略 apply 时记录删除数据, (大数据时可以提高性能)
        public var skipDisplayEventWhenFullyRefreshed: Bool = false
        /// 跳过计算, 直接赋值 (大数据时可以提高性能)
        fileprivate var highestItemSize: CGSize?
        /// 跳过计算, 直接赋值 (大数据时可以提高性能)
        fileprivate var highestHeaderSize: CGSize?
        /// 跳过计算, 直接赋值 (大数据时可以提高性能)
        fileprivate var highestFooterSize: CGSize?
    }
        
    public struct ContextMenuContext: SKCSingleTypeCellActionContextProtocol {
        
        public let section: SKCSingleTypeSection<Cell>
        public let model: Cell.Model
        public let row: Int
        
        init(section: SKCSingleTypeSection<Cell>,
             model: Cell.Model,
             row: Int) {
            self.section = section
            self.model = model
            self.row = row
        }
        
    }
    
    public struct CellActionContext: SKCSingleTypeSectionRowContext, SKCSingleTypeCellActionContextProtocol {
        
        public let section: SKCSingleTypeSection<Cell>
        public let type: SKCCellActionType
        public let model: Cell.Model
        public let row: Int
        public var indexPath: IndexPath { section.indexPath(from: row) }
        fileprivate let _view: SKWeakBox<Cell>?
        
        public func view() -> Cell {
            guard let cell = _view?.value ?? section.cellForItem(at: row) else {
                assertionFailure()
                return .init(frame: .zero)
            }
            return cell
        }
        
        fileprivate init(section: SKCSingleTypeSection<Cell>,
                         type: SKCCellActionType,
                         model: Cell.Model, row: Int,
                         _view: Cell?) {
            self.section = section
            self.type = type
            self.model = model
            self.row = row
            self._view = .init(_view)
        }
    }
    
    public struct SupplementaryActionContext {
        public let section: SKCSingleTypeSection<Cell>
        public let type: SKCSupplementaryActionType
        public let kind: SKSupplementaryKind
        public let row: Int
        let _view: SKWeakBox<UICollectionReusableView>?
        
        public func view() -> UICollectionReusableView {
            guard let cell = _view?.value ?? section.supplementary(kind: kind, at: row) else {
                assertionFailure()
                return .init(frame: .zero)
            }
            return cell
        }
        
        init(section: SKCSingleTypeSection<Cell>,
             type: SKCSupplementaryActionType,
             kind: SKSupplementaryKind,
             row: Int,
             view: UICollectionReusableView?) {
            self.section = section
            self.type = type
            self.kind = kind
            self.row = row
            self._view = .init(view)
        }
    }
    
    public final class SKCSingleTypePublishers {
        
        public var modelsCancellable: AnyCancellable?
        
        /// models 变更订阅
        public private(set) lazy var modelsPulisher = modelsSubject.eraseToAnyPublisher()
        /// cell 事件订阅, 事件类型参照 `CellActionType`
        public private(set) lazy var cellActionPulisher = deferred(bind: \.cellActionSubject)
        /// supplementary 事件订阅, 事件类型参照 `SupplementaryActionType`
        public private(set) lazy var supplementaryActionPulisher = deferred(bind: \.supplementaryActionSubject)
        /// section 生命周期监听
        public private(set) lazy var lifeCyclePulisher = deferred(bind: \.lifeCycleSubject)
            .delay(for: .seconds(0.3), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
        
        fileprivate lazy var modelsSubject = CurrentValueSubject<[Model], Never>([])
        fileprivate var lifeCycleSubject: PassthroughSubject<LifeCycleKind, Never>?
        fileprivate var cellActionSubject: PassthroughSubject<CellActionContext, Never>?
        fileprivate var supplementaryActionSubject: PassthroughSubject<SupplementaryActionContext, Never>?
        
        func deferred<Output, Failure: Error>(bind: WritableKeyPath<SKCSingleTypePublishers, PassthroughSubject<Output, Failure>?>) -> AnyPublisher<Output, Failure> {
            return Deferred { [weak self] in
                guard var self = self else {
                    return PassthroughSubject<Output, Failure>()
                }
                if let subject = self[keyPath: bind] {
                    return subject
                }
                let subject = PassthroughSubject<Output, Failure>()
                self[keyPath: bind] = subject
                return subject
            }
            .eraseToAnyPublisher()
        }
        
    }
    
    open var sectionInjection: SKCSectionInjection?
    
    /// 配置 cell 与 supplementary 的 limit size
    public lazy var safeSizeProvider: SKSafeSizeProvider = defaultSafeSizeProvider
    var safeSizeProviders: [SKSupplementaryKind: SKSafeSizeProvider] = [:]
    
    /// 曝光数, 重置曝光数的时机需要手动控制
    public lazy var displayedTimes: SKCountedStore = .init()
    /// 预加载
    public private(set) lazy var prefetch: SKCPrefetch = .init { [weak self] in
        return self?.itemCount ?? 0
    }
    
    /// cell 对应的数据集
    public internal(set) var models: [Model] {
        set { publishers.modelsSubject.send(newValue) }
        get { publishers.modelsSubject.value }
    }
    
    public var environmentObject: [ObjectIdentifier: Any] = [:]
    public var feature = Feature()
    /// 无数据时隐藏 footerView
    open lazy var hiddenFooterWhenNoItem = true
    /// 无数据时隐藏 headerView
    open lazy var hiddenHeaderWhenNoItem = true
    lazy var supplementaries: [SKSupplementaryKind: any SKCSupplementaryProtocol] = [:]
    
    open lazy var sectionInset: UIEdgeInsets = .zero
    open lazy var minimumLineSpacing: CGFloat = .zero
    open lazy var minimumInteritemSpacing: CGFloat = .zero
    open var itemCount: Int { models.count }
    
    public private(set) lazy var publishers = SKCSingleTypePublishers()
    public var reloadKind: ReloadKind = .normal
    var highPerformance: SKHighPerformanceStore<String>?
    var highPerformanceID: HighPerformanceIDBlock?
    
    lazy var deletedModels: [Int: Model] = [:]
    lazy var cellStyles: [CellStyleBox] = []
    lazy var cellContextMenus: [ContextMenuBlock] = []
    
    lazy var supplementaryActions = SKEventGroup<SKCSupplementaryActionType, SupplementaryActionBlock>()
    lazy var cellActions = SKEventGroup<SKCCellActionType, CellActionBlock>()
    lazy var cellShoulds = SKEventGroup<SKCCellShouldType, CellShouldBlock>()
    
    public var indexTitle: String?
    
    private lazy var loadedTasks: [LoadedBlock] = []
    
    public init(_ models: [Model] = []) {
        self.models = models
    }
    
    public convenience init(_ models: Model...) {
        self.init(models)
    }
    
    open func apply(_ models: [Model]) {
        if !feature.skipDisplayEventWhenFullyRefreshed {
            /// 大数据时会卡, 但是记录会保证 displayed 的正确性
            self.models.enumerated().forEach { item in
                deletedModels[item.offset] = item.element
            }
        }
        reload(models)
    }
    
    open func apply(_ model: Model) {
        apply([model])
    }
    
    open func config(sectionView: UICollectionView) {
        register(Cell.self)
        loadedTasks.forEach { task in
            task(self)
        }
        loadedTasks.removeAll()
        publishers.lifeCycleSubject?.send(.loadedToSectionView(sectionView))
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as Cell
        let model = models[row]
        cell.config(model)
        if !cellStyles.isEmpty {
            let result = SKCCellStyleContext(section: self, model: model, row: row, view: cell)
            cellStyles.forEach { style in
                style.value(result)
            }
        }
        sendAction(.config, view: cell, row: row)
        return cell
    }
    
    open func itemSize(at row: Int) -> CGSize {
        guard models.indices.contains(row) else {
            return .zero
        }
        if let size = feature.highestItemSize {
            return size
        }
        let limitSize = safeSizeProviders[.cell]?.size ?? safeSizeProvider.size
        let model = models[row]
        
        if let highPerformance = highPerformance,
           let ID = highPerformanceID?(.init(model: model, row: row)) {
            return highPerformance.cache(by: ID, limit: limitSize) { limit in
                Cell.preferredSize(limit: limitSize, model: model)
            }
        } else {
            return Cell.preferredSize(limit: limitSize, model: model)
        }
    }
    
    open func item(selected row: Int) {
        sendAction(.selected, view: nil, row: row)
    }
    
    public func item(deselected row: Int) {
        sendAction(.deselected, view: nil, row: row)
    }
    
    open func item(willDisplay view: UICollectionViewCell, row: Int) {
        sendAction(.willDisplay, view: view as? Cell, row: row)
        displayedTimes.update(by: row)
    }
    
    open func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        sendDeleteAction(.didEndDisplay, view: view as? Cell, row: row)
    }
    
    open var headerSize: CGSize {
        if hiddenHeaderWhenNoItem, models.isEmpty {
            return .zero
        }
        guard let supplementary = supplementaries[.header] else {
            return .zero
        }
        if let size = feature.highestHeaderSize {
            return size
        }
        return supplementary.size(safeSizeProviders[.header]?.size ?? safeSizeProvider.size)
    }
    
    open var headerView: UICollectionReusableView? {
        guard let supplementary = supplementaries[.header] else {
            return nil
        }
        return supplementary.dequeue(from: sectionView, indexPath: indexPath(from: 0))
    }
    
    open var footerSize: CGSize {
        if hiddenFooterWhenNoItem, models.isEmpty {
            return .zero
        }
        guard let supplementary = supplementaries[.footer] else {
            return .zero
        }
        if let size = feature.highestFooterSize {
            return size
        }
        return supplementary.size(safeSizeProviders[.footer]?.size ?? safeSizeProvider.size)
    }
    
    open var footerView: UICollectionReusableView? {
        guard let supplementary = supplementaries[.footer] else {
            return nil
        }
        return supplementary.dequeue(from: sectionView, indexPath: indexPath(from: 0))
    }
    
    open func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView? {
        switch kind {
        case .header:
            return headerView
        case .footer:
            return footerView
        case .cell, .custom:
            return nil
        }
    }
    
    open func supplementary(willDisplay view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        sendSupplementaryAction(.willDisplay, kind: kind, row: row, view: view)
    }
    
    open func supplementary(didEndDisplaying view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        sendSupplementaryAction(.didEndDisplay, kind: kind, row: row, view: view)
    }
    
    open func item(canFocus row: Int) -> Bool {
        true
    }
    
    @available(iOS 15.0, *)
    open func item(selectionFollowsFocus row: Int) -> Bool {
        true
    }
    
    @available(iOS 14.0, *)
    open func item(canEdit row: Int) -> Bool {
        false
    }
    
    open func item(shouldSpringLoad row: Int, with context: UISpringLoadedInteractionContext) -> Bool {
        true
    }
    
    open func item(shouldBeginMultipleSelectionInteraction row: Int) -> Bool {
        false
    }
    
    open func item(didBeginMultipleSelectionInteraction row: Int) {
        
    }
    
    /// 预测加载 rows
    /// - Parameter rows: rows
    open func prefetch(at rows: [Int]) {
        self.prefetch.prefetch.send(rows)
    }
    
    /// 取消加载
    /// - Parameter rows: rows
    open func cancelPrefetching(at rows: [Int]) {
        self.prefetch.cancelPrefetching.send(rows)
    }
    
    open func item(canMove row: Int) -> Bool {
        let items = cellShoulds[.move]
        let context = ContextMenuContext(section: self, model: models[row], row: row)
        for item in items {
            if let result = item(context) {
                return result
            }
        }
        return false
    }
    
    public func contextMenu(row: Int, point: CGPoint) -> UIContextMenuConfiguration? {
        return contextMenu(row: row)?.configuration
    }
    
    public func contextMenu(highlightPreview configuration: UIContextMenuConfiguration, row: Int) -> UITargetedPreview? {
        return contextMenu(row: row)?.highlightPreview
    }
    
    public func contextMenu(dismissalPreview configuration: UIContextMenuConfiguration, row: Int) -> UITargetedPreview? {
        return contextMenu(row: row)?.dismissalPreview
    }
    
    public func move(from source: IndexPath, to destination: IndexPath) {
        switch (sectionIndex == source.section, sectionIndex == destination.section) {
        case (true, true):
            models.swapAt(source.item, destination.item)
        case (true, false):
            models.remove(at: source.item)
        case (false, true):
            assertionFailure()
        case (false, false):
            break
        }
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 获取可见的 cell 集合
    var visibleCells: [Cell] {
        return indexsForVisibleItems.compactMap(cellForItem(at:))
    }
    
    /// 获取指定 row 的 Cell
    /// - Parameter row: row
    /// - Returns: cell
    func cellForItem(at row: Int) -> Cell? {
        sectionInjection?.sectionView?.cellForItem(at: indexPath(from: row)) as? Cell
    }
    
}

public extension SKCSingleTypeSection where Model: Equatable {
    
    func scroll(toFirst model: Model?, at scrollPosition: UICollectionView.ScrollPosition = .top, animated: Bool = true) {
        guard let model = model else { return }
        scroll(to: models.firstIndex(where: { $0 == model }), at: scrollPosition, animated: animated)
    }
    
    func scroll(toLast model: Model?, at scrollPosition: UICollectionView.ScrollPosition = .top, animated: Bool = true) {
        guard let model = model else { return }
        scroll(to: models.lastIndex(where: { $0 == model }), at: scrollPosition, animated: animated)
    }
    
    func layoutAttributesForItem(of model: Model) -> [UICollectionViewLayoutAttributes] {
        rows(with: model).compactMap(layoutAttributesForItem(at:))
    }
    
    func firstLayoutAttributesForItem(of model: Model) -> UICollectionViewLayoutAttributes? {
        guard let row = firstRow(of: model) else {
            return nil
        }
        return layoutAttributesForItem(at: row)
    }
    
    func lastLayoutAttributesForItem(of model: Model) -> UICollectionViewLayoutAttributes? {
        guard let row = lastRow(of: model) else {
            return nil
        }
        return layoutAttributesForItem(at: row)
    }
    
    func cellForItem(of models: Model) -> [Cell] {
        rows(with: models).compactMap(cellForItem(at:))
    }
    
    func firstCellForItem(of model: Model) -> Cell? {
        guard let row = firstRow(of: model) else {
            return nil
        }
        return cellForItem(at: row)
    }
    
    func lastCellForItem(of model: Model) -> Cell? {
        guard let row = lastRow(of: model) else {
            return nil
        }
        return cellForItem(at: row)
    }
    
}

@available(*, deprecated, renamed: "safeSize(_:)", message: "")
public extension SKCSingleTypeSection {
    
    @discardableResult
    func apply(safeSize: SKSafeSizeProvider) -> Self {
        safeSizeProvider = safeSize
        return self
    }
    
    @discardableResult
    func apply(safeSize: KeyPath<SKCSingleTypeSection, SKSafeSizeProvider>) -> Self {
        return apply(safeSize: self[keyPath: safeSize])
    }
    
    @discardableResult
    func apply<Root>(safeSize: KeyPath<Root, SKSafeSizeProvider>, on object: Root) -> Self {
        return apply(safeSize: object[keyPath: safeSize])
    }
    
}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func `if`(_ isIncluded: () -> Bool, _ action: SectionStyleBlock) -> Self {
        if isIncluded() {
            action(self)
        }
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func config(models: [Model]) -> Self {
        apply(models)
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    func swapAt(_ i: Int, _ j: Int) {
        guard i != j else {
            return
        }
        let x = min(i, j)
        let y = max(i, j)
        if let sectionView = sectionInjection?.sectionView {
            sectionView.performBatchUpdates {
                models.swapAt(x, y)
                sectionView.moveItem(at: indexPath(from: x), to: indexPath(from: y))
                sectionView.moveItem(at: indexPath(from: y), to: indexPath(from: x))
            }
        } else {
            models.swapAt(x, y)
        }
    }
    
}

private extension SKCSingleTypeSection {
    
    func reload(_ model: Model) {
        reload([model])
    }
    
    func reload(_ models: [Model])  {
        switch reloadKind {
        case .difference(by: let areEquivalent):
            self.reload(models: models, by: areEquivalent)
        case .configAndDelete:
            if models.count < self.models.count {
                self.models = models
                sectionInjection?.reload()
            } else {
                if self.models.count > models.count {
                    let rows = Array((0..<self.models.count).dropFirst(models.count))
                    self.remove(rows)
                }
                self.models = models
                for (index, model) in models.enumerated() {
                    if let cell = self.cellForItem(at: index) {
                        cell.config(model)
                    } else {
                        sectionInjection?.reload()
                    }
                }
            }
            
            //            if self.isBindSectionView, let headerView = headerView {
            //                sendSupplementaryAction(.reload, kind: .header, row: 0, view: headerView)
            //            }
            //            
            //            if self.isBindSectionView, let footerView = footerView {
            //                sendSupplementaryAction(.reload, kind: .footer, row: 0, view: footerView)
            //            }
        case .normal:
            self.models = models
            sectionInjection?.reload()
        }
    }
    
    func reload(models: [Model], by areEquivalent: (Model, Model) -> Bool) {
        if models.isEmpty || self.models.isEmpty {
            self.models = models
            sectionInjection?.reload()
            return
        } else {
            let difference = models.difference(from: self.models, by: areEquivalent)
            sectionInjection?.pick({
                for change in difference {
                    switch change {
                    case .remove(let offset, _, _):
                        self.delete(offset)
                    case .insert(let offset, let model, _):
                        self.insert(at: offset, model)
                    }
                }
            }, completion: { flag in
                
            })
        }
    }
    
}

public extension SKCSingleTypeSection {
    
    func append(_ items: [Model]) {
        insert(at: models.count, items)
    }
    
    func append(_ item: Model) {
        append([item])
    }
    
    func insert(at row: Int, _ items: [Model]) {
        guard !items.isEmpty else {
            return
        }
        if let sectionView = sectionInjection?.sectionView {
            sectionView.performBatchUpdates {
                models.insert(contentsOf: items, at: row)
                sectionView.insertItems(at: (row..<(row + items.count)).map(indexPath(from:)))
            }
        } else {
            models.insert(contentsOf: items, at: row)
        }
    }
    
    func insert(at row: Int, _ item: Model) {
        insert(at: row, [item])
    }
    
}

public extension SKCSingleTypeSection {
    
    func remove(_ row: Int) {
        remove([row])
    }
    
    func remove(_ rows: [Int]) {
        remove(rows, applySectionView: true)
    }
    
    func remove(_ rows: [Int], applySectionView: Bool) {
        var set = Set<Int>()
        let rows = rows
            .filter { set.insert($0).inserted }
            .filter { models.indices.contains($0) }
            .sorted(by: >)
        guard !rows.isEmpty, applySectionView else {
            return
        }
        if let sectionView = sectionInjection?.sectionView {
            sectionView.performBatchUpdates {
                for row in rows {
                    deletedModels[row] = models.remove(at: row)
                }
                sectionView.deleteItems(at: rows.map(indexPath(from:)))
            } completion: { flag in
                let max = self.models.count
                if let min = rows.min(), max > min {
                    self.sectionInjection?.reload(cell: Array(min..<max))
                } else {
                    self.sectionInjection?.reload()
                }
            }
        } else {
            rows.sorted(by: >).forEach { index in
                models.remove(at: index)
            }
        }
    }
    
    func remove(where predicate: (Model) throws -> Bool) {
        let rows = try? models.enumerated().filter { try predicate($0.element) }.map(\.offset)
        remove(rows ?? [])
    }
    
    func remove(_ item: Model) where Model: Equatable {
        remove(rows(with: item))
    }
    
    func remove(_ items: [Model]) where Model: Equatable {
        remove(rows(with: items))
    }
    
    func remove(_ item: Model) where Model: AnyObject {
        remove(rows(with: item))
    }
    
    func remove(_ items: [Model]) where Model: AnyObject {
        remove(rows(with: items))
    }
    
}

public extension SKCSingleTypeSection {
    
    func delete(_ row: Int) {
        remove(row)
    }
    
    func delete(_ rows: [Int]) {
        remove(rows)
    }
    
    func delete(where predicate: (Model) throws -> Bool) {
        remove(where: predicate)
    }
    
    func delete(_ item: Model) where Model: Equatable {
        remove(item)
    }
    
    func delete(_ items: [Model]) where Model: Equatable {
        remove(items)
    }
    
    func delete(_ item: Model) where Model: AnyObject {
        remove(item)
    }
    
    func delete(_ items: [Model]) where Model: AnyObject {
        remove(items)
    }
    
}

public extension SKCSingleTypeSection {
    
    func firstRow(of item: Model) -> Int? where Model: Equatable {
        self.models.firstIndex(of: item)
    }
    
    func lastRow(of item: Model) -> Int? where Model: Equatable {
        self.models.lastIndex(of: item)
    }
    
    func rows(with item: Model) -> [Int] where Model: Equatable {
        self.models
            .enumerated()
            .filter { $0.element == item }
            .map(\.offset)
    }
    
    func rows(with items: [Model]) -> [Int] where Model: Equatable  {
        self.models
            .enumerated()
            .filter { items.contains($0.element) }
            .map(\.offset)
    }
    
    func rows(with item: Model) -> [Int] where Model: AnyObject {
        rows(with: [item])
    }
    
    func rows(with items: [Model]) -> [Int] where Model: AnyObject {
        let items = Set(items.map({ ObjectIdentifier($0) }))
        return self.models
            .enumerated()
            .filter { items.contains(ObjectIdentifier($0.element)) }
            .map(\.offset)
    }
    
}

public extension SKCSingleTypeSection {
    
    func deselectItem(at row: Int, animated: Bool = true) {
        sectionView.deselectItem(at: indexPath(from: row), animated: animated)
    }
    
    func deselectItem(at item: Model, animated: Bool = true) where Model: Equatable {
        rows(with: item)
            .forEach { index in
                self.deselectItem(at: index, animated: animated)
            }
    }
    
    func deselectItem(at item: Model, animated: Bool = true) where Model: AnyObject {
        rows(with: item)
            .forEach { index in
                self.deselectItem(at: index, animated: animated)
            }
    }
    
    func selectItem(at row: Int, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = .bottom) {
        sectionView.selectItem(at: indexPath(from: row), animated: animated, scrollPosition: scrollPosition)
    }
    
    func selectItem(at item: Model, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = .bottom) where Model: Equatable {
        rows(with: item)
            .forEach { index in
                self.selectItem(at: index, animated: animated, scrollPosition: scrollPosition)
            }
    }
    
    func selectItem(at item: Model, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = .bottom) where Model: AnyObject {
        rows(with: item)
            .forEach { index in
                self.selectItem(at: index, animated: animated, scrollPosition: scrollPosition)
            }
    }
    
}

public extension SKCSingleTypeSection {
    
    func contextMenu(row: Int) -> SKUIContextMenuResult? {
        if cellContextMenus.isEmpty {
            return nil
        }
        let model = models[row]
        let context = ContextMenuContext(section: self, model: model, row: row)
        for cellContextMenu in cellContextMenus {
            if let result = cellContextMenu(context) {
                return result
            }
        }
        return nil
    }
    
    func sendDeleteAction(_ type: SKCCellActionType, view: Cell?, row: Int) {
        guard deletedModels[row] != nil || models.indices.contains(row) else {
            return
        }
        let result = CellActionContext(section: self,
                                       type: type,
                                       model: deletedModels[row] ?? models[row],
                                       row: row, _view: view)
        deletedModels[row] = nil
        sendAction(result)
    }
    
    func sendAction(_ type: SKCCellActionType, view: Cell?, row: Int) {
        guard models.indices.contains(row) else { return }
        let result = CellActionContext(section: self, type: type, model: models[row], row: row, _view: view)
        sendAction(result)
    }
    
    func sendAction(_ result: CellActionContext) {
        for block in cellActions[result.type] {
            block(result)
        }
        publishers.cellActionSubject?.send(result)
    }
    
    func sendSupplementaryAction(_ type: SKCSupplementaryActionType,
                                 kind: SKSupplementaryKind,
                                 row: Int,
                                 view: UICollectionReusableView) {
        let result = SupplementaryActionContext(section: self, type: type, kind: kind, row: row, view: view)
        for block in supplementaryActions[type] {
            block(result)
        }
        publishers.supplementaryActionSubject?.send(result)
    }
    
    func taskIfLoaded(_ task: @escaping LoadedBlock) {
        if self.sectionInjection?.sectionView != nil {
            task(self)
        } else {
            loadedTasks.append(task)
        }
    }
    
}

#endif
