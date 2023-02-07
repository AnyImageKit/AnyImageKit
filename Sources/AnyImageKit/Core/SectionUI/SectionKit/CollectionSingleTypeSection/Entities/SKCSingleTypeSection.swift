//
//  File.swift
//  
//
//  Created by linhey on 2022/8/18.
//

import UIKit
import Combine

open class SKCSingleTypeSection<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: SKCSingleTypeSectionProtocol {
    
    public typealias CellStyleBox = IDBox<UUID, CellStyleBlock>
    
    public typealias SectionStyleBlock = (_ section: SKCSingleTypeSection<Cell>) -> Void
    public typealias LoadedBlock = (_ section: SKCSingleTypeSection<Cell>) -> Void
    
    public typealias SupplementaryActionBlock = (_ context: SupplementaryActionContext) -> Void
    public typealias ContextMenuBlock = (_ context: ContextMenuContext) -> ContextMenuResult?
    public typealias CellActionBlock  = (_ context: CellActionContext) -> Void
    public typealias CellStyleBlock   = (_ context: CellStyleContext) -> Void
    
    public enum LifeCycleKind {
        case loadedToSectionView(UICollectionView)
    }
    
    public enum CellActionType: Int, Hashable {
        /// 选中
        case selected
        /// 即将显示
        case willDisplay
        /// 结束显示
        case didEndDisplay
        /// 配置完成
        case config
    }
    
    public enum SupplementaryActionType: Int, Hashable {
        /// 即将显示
        case willDisplay
        /// 结束显示
        case didEndDisplay
    }
    
    public struct ContextMenuContext {
        
        public let section: SKCSingleTypeSection<Cell>
        public let model: Cell.Model
        public let row: Int?
        
        init(section: SKCSingleTypeSection<Cell>, model: Cell.Model, row: Int?) {
            self.section = section
            self.model = model
            self.row = row
        }
        
    }
    
    public struct ContextMenuResult {
        
        public var configuration: UIContextMenuConfiguration
        public var highlightPreview: UITargetedPreview?
        public var dismissalPreview: UITargetedPreview?
        
        public init(configuration: UIContextMenuConfiguration,
                    highlightPreview: UITargetedPreview? = nil,
                    dismissalPreview: UITargetedPreview? = nil) {
            self.configuration = configuration
            self.highlightPreview = highlightPreview
            self.dismissalPreview = dismissalPreview
        }
        
        public init(actions: [UIAction]) {
            self.init(configuration: .init(actionProvider: { suggest in
                return UIMenu(children: actions)
            }))
        }
        
    }
    
    public struct CellActionContext {
        
        public let section: SKCSingleTypeSection<Cell>
        public let type: CellActionType
        public let model: Cell.Model
        public let row: Int
        fileprivate let _view: SKWeakBox<Cell>?
        
        public func view() -> Cell {
            guard let cell = _view?.value ?? section.cellForItem(at: row) else {
                assertionFailure()
                return .init(frame: .zero)
            }
            return cell
        }
        
        fileprivate init(section: SKCSingleTypeSection<Cell>,
                         type: CellActionType,
                         model: Cell.Model, row: Int,
                         _view: Cell?) {
            self.section = section
            self.type = type
            self.model = model
            self.row = row
            self._view = .init(_view)
        }
    }
    
    public struct CellStyleContext {
        
        public let model: Cell.Model
        public let row: Int
        public let view: Cell
        public let section: SKCSingleTypeSection<Cell>
        
        fileprivate init(section: SKCSingleTypeSection<Cell>, model: Cell.Model, row: Int, view: Cell) {
            self.row = row
            self.model = model
            self.section = section
            self.view = view
        }
        
    }
    
    public struct SupplementaryActionContext {
        public let section: SKCSingleTypeSection<Cell>
        public let type: SupplementaryActionType
        public let kind: SKSupplementaryKind
        public let row: Int
    }
    
    public struct IDBox<ID, Value> {
        
        public typealias ID = ID
        public let id: ID
        public let value: Value
        
        public init(id: ID, value: Value) {
            self.id = id
            self.value = value
        }
        
        public init(value: Value) where ID == UUID {
            self.id = UUID()
            self.value = value
        }
        
    }
    
    public class Pulishers {
        
        /// models 变更订阅
        public private(set) lazy var modelsPulisher = modelsSubject.eraseToAnyPublisher()
        /// cell 事件订阅, 事件类型参照 `CellActionType`
        public private(set) lazy var cellActionPulisher = cellActionSubject.eraseToAnyPublisher()
        /// supplementary 事件订阅, 事件类型参照 `SupplementaryActionType`
        public private(set) lazy var supplementaryActionPulisher = supplementaryActionSubject.eraseToAnyPublisher()
        /// section 生命周期监听
        public private(set) lazy var lifeCyclePulisher = lifeCycleSubject
            .delay(for: .seconds(0.3), scheduler: RunLoop.main)
            .eraseToAnyPublisher()

        fileprivate lazy var modelsSubject = CurrentValueSubject<[Model], Never>([])
        fileprivate lazy var lifeCycleSubject = PassthroughSubject<LifeCycleKind, Never>()
        fileprivate lazy var cellActionSubject = PassthroughSubject<CellActionContext, Never>()
        fileprivate lazy var supplementaryActionSubject = PassthroughSubject<SupplementaryActionContext, Never>()
    }
    
    open var sectionInjection: SKCSectionInjection?
    
    /// 配置 cell 与 supplementary 的 limit size
    public lazy var safeSizeProvider: SKSafeSizeProvider = defaultSafeSizeProvider
    
    /// 预加载
    public private(set) lazy var prefetch: SKCPrefetch = .init { [weak self] in
        return self?.itemCount ?? 0
    }
    
    /// cell 对应的数据集
    public private(set) var models: [Model] {
        set { pulishers.modelsSubject.send(newValue) }
        get { pulishers.modelsSubject.value }
    }
    
    /// 无数据时隐藏 footerView
    open lazy var hiddenFooterWhenNoItem = true
    /// 无数据时隐藏 headerView
    open lazy var hiddenHeaderWhenNoItem = true
    
    open lazy var sectionInset: UIEdgeInsets = .zero
    open lazy var minimumLineSpacing: CGFloat = .zero
    open lazy var minimumInteritemSpacing: CGFloat = .zero
    open var itemCount: Int { models.count }
    
    public private(set) lazy var pulishers = Pulishers()
    
    private lazy var deletedModels: [Int: Model] = [:]
    private lazy var supplementaries: [SKSupplementaryKind: any SKCSupplementaryProtocol] = [:]
    private lazy var supplementaryActions: [SupplementaryActionType: [SupplementaryActionBlock]] = [:]
    private lazy var cellActions: [CellActionType: [CellActionBlock]] = [:]
    private lazy var cellStyles: [CellStyleBox] = []
    private lazy var cellContextMenus: [ContextMenuBlock] = []
    private lazy var loadedTasks: [LoadedBlock] = []
    
    public init(_ models: [Model] = []) {
        self.models = models
    }
    
    public convenience init(_ models: Model...) {
        self.init(models)
    }
    
    open func apply(_ models: [Model]) {
        models.enumerated().forEach { item in
            deletedModels[item.offset] = item.element
        }
        reload(models)
    }
    
    open func apply(_ model: Model) {
        append([model])
    }
    
    open func config(sectionView: UICollectionView) {
        register(Cell.self)
        loadedTasks.forEach { task in
            task(self)
        }
        pulishers.lifeCycleSubject.send(.loadedToSectionView(sectionView))
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as Cell
        let model = models[row]
        cell.config(model)
        if !cellStyles.isEmpty {
            let result = CellStyleContext(section: self, model: model, row: row, view: cell)
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
        return Cell.preferredSize(limit: safeSizeProvider.size, model: models[row])
    }
    
    open func item(selected row: Int) {
        sendAction(.selected, view: nil, row: row)
    }
    
    open func item(willDisplay view: UICollectionViewCell, row: Int) {
        sendAction(.willDisplay, view: view as? Cell, row: row)
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
        return supplementary.size(safeSizeProvider.size)
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
        return supplementary.size(safeSizeProvider.size)
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
        sendSupplementaryAction(.willDisplay, kind: kind, row: row)
    }
    
    open func supplementary(didEndDisplaying view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        sendSupplementaryAction(.didEndDisplay, kind: kind, row: row)
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
        sectionView.cellForItem(at: indexPath(from: row)) as? Cell
    }
    
}

public extension SKCSingleTypeSection where Model: Equatable {
    
    func scroll(toFirst model: Model, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        scroll(to: models.firstIndex(where: { $0 == model }), at: scrollPosition, animated: animated)
    }
    
    func scroll(toLast model: Model, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
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

public extension SKCSingleTypeSection {
    
    @discardableResult
    func config(models: [Model]) -> Self {
        apply(models)
        return self
    }
    
    
    @discardableResult
    func remove(supplementary kind: SKSupplementaryKind) -> Self {
        supplementaries[kind] = nil
        reload()
        return self
    }
    
    @discardableResult
    func set<T>(supplementary: SKCSupplementary<T>) -> Self {
        taskIfLoaded { section in
            section.register(supplementary.type, for: supplementary.kind)
        }
        supplementaries[supplementary.kind] = supplementary
        reload()
        return self
    }
    
    @discardableResult
    func set<View>(supplementary kind: SKSupplementaryKind,
                   type: View.Type,
                   config: ((View) -> Void)? = nil,
                   size: @escaping (_ limitSize: CGSize) -> CGSize) -> Self where View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView {
        set(supplementary: .init(kind: kind, type: type, config: config, size: size))
    }
    
    @discardableResult
    func set<View>(supplementary kind: SKSupplementaryKind,
                   type: View.Type,
                   model: View.Model,
                   config: ((View) -> Void)? = nil) -> Self where View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView & SKConfigurableView {
        set(supplementary: .init(kind: kind, type: type) { view in
            view.config(model)
            config?(view)
        } size: { limitSize in
            View.preferredSize(limit: limitSize, model: model)
        })
    }
    
    @discardableResult
    func set<View>(supplementary kind: SKSupplementaryKind,
                   type: View.Type,
                   config: ((View) -> Void)? = nil) -> Self where View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView & SKConfigurableView, View.Model == Void {
        set(supplementary: kind, type: type, model: (), config: config)
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

/// 指定更新
public extension SKCSingleTypeSection {
    
    func refresh(_ model: Model) where Model: Equatable {
        self.refresh([model])
    }
    
    func refresh(_ models: [Model]) where Model: Equatable {
        sectionInjection?.reload(cell: rows(with: models))
    }
    
    func refresh(_ model: Model) where Model: AnyObject {
        self.refresh([model])
    }
    
    func refresh(_ models: [Model]) where Model: AnyObject {
        let indexs = models
            .enumerated()
            .compactMap { item in
                models.contains(where: { $0 === item.element }) ? item.offset : nil
            }
        sectionInjection?.reload(cell: indexs)
    }
    
    func refresh(at row: Int) {
        sectionInjection?.reload(cell: row)
    }
    
    func refresh(at row: [Int]) {
        sectionInjection?.reload(cell: row)
    }
    
}

private extension SKCSingleTypeSection {
    
    func reload(_ model: Model) {
        reload([model])
    }
    
    func reload(_ models: [Model]) {
        self.models = models
        sectionInjection?.reload()
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
        var set = Set<Int>()
        let rows = rows
            .filter { set.insert($0).inserted }
            .filter { models.indices.contains($0) }
            .sorted(by: >)
        guard !rows.isEmpty else {
            return
        }
        
        if let sectionView = sectionInjection?.sectionView {
            sectionView.performBatchUpdates {
                for row in rows {
                    deletedModels[row] = models.remove(at: row)
                }
                sectionView.deleteItems(at: rows.map(indexPath(from:)))
            } completion: { flag in
                self.sectionInjection?.reload(cell: (rows.min()!..<self.models.count))
            }
        } else {
            rows.sorted(by: >).forEach { index in
                models.remove(at: index)
            }
        }
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
    
    /// 配置当前 section 样式
    /// - Parameter item: 回调
    /// - Returns: self
    @discardableResult
    func setSectionStyle(_ item: @escaping SectionStyleBlock) -> Self {
        item(self)
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 订阅事件类型
    /// - Parameters:
    ///   - kind: 事件类型
    ///   - block: 回调
    /// - Returns: self
    @discardableResult
    func onCellAction(_ kind: CellActionType, block: @escaping CellActionBlock) -> Self {
        if cellActions[kind] == nil {
            cellActions[kind] = []
        }
        cellActions[kind]?.append(block)
        return self
    }
    
    func onContextMenu(_ block: @escaping ContextMenuBlock) -> Self {
        cellContextMenus.append(block)
        return self
    }
    
    @discardableResult
    func setCellStyle(_ item: @escaping CellStyleBlock) -> Self {
        return setCellStyle(.init(value: item))
    }
    
    @discardableResult
    func setCellStyle(_ item: CellStyleBox) -> Self {
        cellStyles.append(item)
        return self
    }
    
    func remove(cellStyle ids: [CellStyleBox.ID]) {
        let ids = Set(ids)
        self.cellStyles = cellStyles.filter { !ids.contains($0.id) }
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 订阅事件类型
    /// - Parameters:
    ///   - kind: 事件类型
    ///   - block: 回调
    /// - Returns: self
    @discardableResult
    func onSupplementaryAction(_ kind: SupplementaryActionType, block: @escaping SupplementaryActionBlock) -> Self {
        if supplementaryActions[kind] == nil {
            supplementaryActions[kind] = []
        }
        supplementaryActions[kind]?.append(block)
        return self
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
    
    func contextMenu(row: Int) -> ContextMenuResult? {
        let model = models[row]
        let context = ContextMenuContext(section: self, model: model, row: row)
        for cellContextMenu in cellContextMenus {
            if let result = cellContextMenu(context) {
                return result
            }
        }
        return nil
    }
    
    func sendDeleteAction(_ type: CellActionType, view: Cell?, row: Int) {
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
    
    func sendAction(_ type: CellActionType, view: Cell?, row: Int) {
        let result = CellActionContext(section: self, type: type, model: models[row], row: row, _view: view)
        sendAction(result)
    }
    
    func sendAction(_ result: CellActionContext) {
        cellActions[result.type]?.forEach({ block in
            block(result)
        })
        pulishers.cellActionSubject.send(result)
    }
    
    func sendSupplementaryAction(_ type: SupplementaryActionType, kind: SKSupplementaryKind, row: Int) {
        let result = SupplementaryActionContext(section: self, type: type, kind: kind, row: row)
        supplementaryActions[type]?.forEach({ block in
            block(result)
        })
        pulishers.supplementaryActionSubject.send(result)
    }
    
    func taskIfLoaded(_ task: @escaping LoadedBlock) {
        if self.sectionInjection != nil {
            task(self)
        } else {
            loadedTasks.append(task)
        }
    }
    
}
