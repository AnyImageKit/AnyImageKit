//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public protocol SKCRegistrationSectionProtocol: SKCDataSourceProtocol,
                                                SKCSectionActionProtocol,
                                                SKCViewDelegateFlowLayoutProtocol,
                                                SKCViewDataSourcePrefetchingProtocol,
                                                SKSafeSizeProviderProtocol {
    
    var prefetch: SKCPrefetch { get }
    /// SupplementaryView 集合
    var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol] { get set }
    /// Cell 集合
    var registrations: [any SKCCellRegistrationProtocol] { get set }
    /// manager 注入功能
    var registrationSectionInjection: SKCRegistrationSectionInjection? { get set }
    /// manager 设置 `registrationSectionInjection`
    /// - Parameter injection: injection
    func prepare(injection: SKCRegistrationSectionInjection?)
    
}

public extension SKCRegistrationSectionProtocol {
    
    var sectionInjection: SKCSectionInjection? {
        set { registrationSectionInjection = newValue as? SKCRegistrationSectionInjection }
        get { registrationSectionInjection }
    }
    
}

public extension SKCRegistrationSectionProtocol {
    
    func move(from source: IndexPath, to destination: IndexPath) {
        switch (sectionIndex == source.section, sectionIndex == destination.section) {
        case (true, true):
            registrations.swapAt(source.item, destination.item)
        case (true, false):
            registrations.remove(at: source.item)
        case (false, true):
            assertionFailure()
        case (false, false):
            break
        }
    }
    
    @discardableResult
    func setSectionStyle(_ builder: (_ section: Self) -> Void) -> Self {
        builder(self)
        return self
    }
    
}


public extension SKCRegistrationSectionProtocol {
    
    func supplementary(_ kind: SKSupplementaryKind) -> (any SKCSupplementaryRegistrationProtocol)? {
        return supplementaries[kind]
    }
    
    func registration(at row: Int) -> (any SKCCellRegistrationProtocol)? {
        guard registrations.indices.contains(row) else {
            assertionFailure()
            return nil
        }
        return registrations[row]
    }
    
    var safeSizeProvider: SKSafeSizeProvider { defaultSafeSizeProvider }
    
    var itemCount: Int { registrations.count }
    
    func item(at row: Int) -> UICollectionViewCell {
        let cell = registration(at: row)?.dequeue(sectionView: sectionView)
        return cell ?? .init()
    }
    
    func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView? {
        supplementary(kind)?.dequeue(sectionView: sectionView, kind: kind)
    }
    
    func itemSize(at row: Int) -> CGSize {
        return registration(at: row)?.preferredSize(limit: safeSizeProvider.size) ?? .zero
    }
    
    var headerView: UICollectionReusableView? {
        supplementary(kind: .header, at: 0)
    }
    
    var footerView: UICollectionReusableView? {
        supplementary(kind: .footer, at: 0)
    }
    
    var headerSize: CGSize {
        supplementary(.header)?.preferredSize(limit: safeSizeProvider.size) ?? .zero
    }
    
    var footerSize: CGSize {
        supplementary(.footer)?.preferredSize(limit: safeSizeProvider.size) ?? .zero
    }
    
    func item(shouldHighlight row: Int) -> Bool {
        registration(at: row)?.shouldHighlight?() ?? true
    }
    
    func item(didHighlight row: Int) {
        registration(at: row)?.onHighlight?()
    }
    
    func item(didUnhighlight row: Int) {
        registration(at: row)?.onUnhighlight?()
    }
    
    func item(shouldSelect row: Int) -> Bool {
        registration(at: row)?.shouldHighlight?() ?? true
    }
    func item(shouldDeselect row: Int) -> Bool {
        registration(at: row)?.shouldDeselect?() ?? true
    }
    
    func item(selected row: Int) {
        registration(at: row)?.onSelected?()
    }
    
    func item(deselected row: Int) {
        registration(at: row)?.onDeselected?()
    }
    
    @available(iOS 16.0, *)
    func item(canPerformPrimaryAction row: Int) -> Bool {
        registration(at: row)?.canPerformPrimaryAction?() ?? true
    }
    
    @available(iOS 16.0, *)
    func item(performPrimaryAction row: Int) {
        registration(at: row)?.onPerformPrimaryAction?()
    }
    
    func item(willDisplay view: UICollectionViewCell, row: Int) {
        registration(at: row)?.onWillDisplay?()
    }
    
    func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        (registrationSectionInjection?.registration(at: row) ?? registration(at: row))?.onEndDisplaying?()
    }
    
    func supplementary(willDisplay view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        (registrationSectionInjection?.supplementary(kind) ?? supplementary(kind))?.onWillDisplay?()
    }
    
    func supplementary(didEndDisplaying view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        (registrationSectionInjection?.supplementary(kind) ?? supplementary(kind))?.onEndDisplaying?()
    }
    
    func item(canFocus row: Int) -> Bool {
        registration(at: row)?.canFocus?() ?? true
    }
    
    @available(iOS 15.0, *)
    func item(selectionFollowsFocus row: Int) -> Bool {
        registration(at: row)?.selectionFollowsFocus?() ?? true
    }
    
    @available(iOS 14.0, *)
    func item(canEdit row: Int) -> Bool {
        registration(at: row)?.canEdit?() ?? false
    }
    
    func item(shouldSpringLoad row: Int, with context: UISpringLoadedInteractionContext) -> Bool {
        registration(at: row)?.shouldSpringLoad?(context) ?? true
    }
    
    func item(shouldBeginMultipleSelectionInteraction row: Int) -> Bool {
        registration(at: row)?.shouldBeginMultipleSelectionInteraction?() ?? false
    }
    
    func item(didBeginMultipleSelectionInteraction row: Int) {
        registration(at: row)?.onBeginMultipleSelectionInteraction?()
    }
}


public extension SKCRegistrationSectionProtocol {
    
    func prepare(injection: SKCRegistrationSectionInjection?) {
        guard let injection = injection else {
            supplementaries.forEach { item in
                item.value.injection = nil
            }
            registrations.forEach { item in
                item.injection = nil
            }
            return
        }
        
        self.registrationSectionInjection = injection
        prepare(injection: injection, with: supplementaries)
        prepare(injection: injection, with: registrations, offset: 0)
    }
    
}

public extension SKCRegistrationSectionProtocol {
    
    /// 重置所有 Supplementary 视图
    func apply(supplementary items: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol]) {
        guard let injection = registrationSectionInjection else {
            self.supplementaries = items
            return
        }
        self.supplementaries = items
        self.prepare(injection: injection, with: supplementaries)
        injection.send(.reload)
    }
    
    /// 重置所有 Supplementary 视图
    func apply(supplementary items: (any SKCSupplementaryRegistrationProtocol)...) {
        apply(supplementary: items)
    }
    
    /// 重置所有 Supplementary 视图
    func apply(supplementary items: [any SKCSupplementaryRegistrationProtocol]) {
        apply(supplementary: self.supplementaries(items))
    }
    
    func delete(supplementary item: any SKCSupplementaryRegistrationProtocol) {
        delete(supplementary: [item])
    }
    
    func delete(supplementary items: [any SKCSupplementaryRegistrationProtocol]) {
        let set = Set(items.map(\.kind))
        supplementaries = supplementaries.filter({ item in
            if set.contains(item.value.kind) {
                registrationSectionInjection?.supplementaries[item.value.kind] = item.value
                return false
            } else {
                return true
            }
        })
        sectionInjection?.send(.reload)
    }
    
    func insert(supplementary items: (any SKCSupplementaryRegistrationProtocol)...) {
        insert(supplementary: items)
    }
    
    func insert(supplementary items: [any SKCSupplementaryRegistrationProtocol]) {
        guard !items.isEmpty else {
            return
        }
        items.forEach { item in
            supplementaries[item.kind] = item
        }
        guard let injection = registrationSectionInjection else {
            return
        }
        prepare(injection: injection, with: self.supplementaries(items))
        sectionInjection?.send(.reload)
    }
    
}

public extension SKCRegistrationSectionProtocol {
    
    /// 重置所有 Cell 视图
    func apply(cell registrations: any SKCCellRegistrationProtocol) {
        apply(cell: [registrations])
    }
    
    /// 重置所有 Cell 视图
    func apply(cell registrations: [any SKCCellRegistrationProtocol]) {
        self.registrations = registrations
        guard let injection = registrationSectionInjection else {
            return
        }
        self.prepare(injection: injection, with: registrations, offset: 0)
        injection.send(.reload)
    }
    
    func delete(cell item: any SKCCellRegistrationProtocol) {
        delete(cell: [item])
    }
    
    func delete(cell items: [any SKCCellRegistrationProtocol]) {
        let set = Set(items.compactMap(\.indexPath?.row))
        let registrations = registrations
            .filter({ item in
                guard let indexPath = item.indexPath else {
                    return false
                }
                
                if set.contains(indexPath.row) {
                    registrationSectionInjection?.registrations[indexPath.row] = item
                    return false
                } else {
                    return true
                }
            })
        guard let injection = registrationSectionInjection else {
            self.registrations = registrations
            return
        }
        self.registrations = resetIndex(injection: injection, registrations: registrations, offset: 0)
        injection.delete(cell: Array(set))
    }
    
    func reload(cell items: (any SKCCellRegistrationProtocol)...) {
        reload(cell: items)
    }
    
    func reload(cell items: [any SKCCellRegistrationProtocol]) {
        let set = Set(registrations.map(ObjectIdentifier.init))
        let union = items.filter { item in
            set.contains(.init(item))
        }.compactMap(\.indexPath?.row)
        guard let injection = registrationSectionInjection else {
            return
        }
        injection.reload(cell: union)
    }
    
    func insert(cell items: (any SKCCellRegistrationProtocol)..., at row: Int) {
        insert(cell: items, at: row)
    }
    
    func insert(cell items: [any SKCCellRegistrationProtocol], at row: Int) {
        guard !items.isEmpty else {
            return
        }
        self.registrations.insert(contentsOf: items, at: row)
        guard let injection = registrationSectionInjection else {
            return
        }
        prepare(injection: injection, with: items, offset: row)
        let offset = row + items.count
        resetIndex(injection: injection, registrations: registrations.dropFirst(offset), offset: offset)
        injection.insert(cell: items.compactMap(\.indexPath?.row))
    }
}

public extension SKCRegistrationSectionProtocol {
    
    /// 重置所有视图
    @discardableResult
    func apply<T: AnyObject>(on object: T, @SKCRegistrationSectionBuilder _ builder: ((_ object: T, _ section: Self) -> [SKCRegistrationSectionBuilderStore])) -> Self {
        return self.apply { [weak object, weak self] in
            if let object = object, let self = self {
                builder(object, self)
            }
        }
    }
    
    /// 重置所有视图
    @discardableResult
    func apply(@SKCRegistrationSectionBuilder _ builder: (() -> [SKCRegistrationSectionBuilderStore])) -> Self {
        let stores = builder()
        var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol] = [:]
        var registrations: [any SKCCellRegistrationProtocol] = []
        
        for store in stores {
            switch store {
            case .supplementary(let item):
                supplementaries[item.kind] = item
            case .registration(let item):
                registrations.append(item)
            }
        }
        
        self.apply(supplementary: supplementaries)
        self.apply(cell: registrations)
        return self
    }
    
    /// 插入视图
    @discardableResult
    func insert<T: AnyObject>(on object: T, at row: Int, @SKCRegistrationSectionBuilder _ builder: ((_ object: T, _ section: Self) -> [SKCRegistrationSectionBuilderStore])) -> Self {
        return self.insert(at: row) { [weak object, weak self] in
            if let object = object, let self = self {
                builder(object, self)
            }
        }
    }
    
    /// 插入视图
    @discardableResult
    func insert(at row: Int, @SKCRegistrationSectionBuilder _ builder: (() -> [SKCRegistrationSectionBuilderStore])) -> Self {
        let stores = builder()
        var supplementaries: [any SKCSupplementaryRegistrationProtocol] = []
        var registrations: [any SKCCellRegistrationProtocol] = []
        
        for store in stores {
            switch store {
            case .supplementary(let item):
                supplementaries.append(item)
            case .registration(let item):
                registrations.append(item)
            }
        }
        
        self.insert(supplementary: supplementaries)
        self.insert(cell: registrations, at: row)
        return self
    }
    
}

/// SKCViewDataSourcePrefetchingProtocol
public extension SKCRegistrationSectionProtocol {
    
    /// 预测加载 rows
    /// - Parameter rows: rows
    func prefetch(at rows: [Int]) {
        prefetch.prefetch.send(rows)
    }
    
    /// 取消加载
    /// - Parameter rows: rows
    func cancelPrefetching(at rows: [Int]) {
        prefetch.cancelPrefetching.send(rows)
    }
    
}


private extension SKCRegistrationSectionProtocol {
    
    func supplementaries(_ items: [any SKCSupplementaryRegistrationProtocol]) -> [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol] {
        var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol] = [:]
        for item in items {
            supplementaries[item.kind] = item
        }
        return supplementaries
    }

    @discardableResult
    private func resetIndex(injection: SKCRegistrationSectionInjection,
                            registrations: ArraySlice<any SKCCellRegistrationProtocol>,
                            offset: Int) -> [any SKCCellRegistrationProtocol] {
        return resetIndex(injection: injection, registrations: Array(registrations), offset: offset)
    }
    
    private func resetIndex(injection: SKCRegistrationSectionInjection,
                            registrations: [any SKCCellRegistrationProtocol],
                            offset: Int) -> [any SKCCellRegistrationProtocol] {
        return registrations
            .enumerated()
            .map { item in
                var element = item.element
                element.indexPath = .init(item: offset + item.offset, section: injection.index)
                return element
            }
    }
    
    func prepare(injection: SKCRegistrationSectionInjection,
                 with supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol]) {
        supplementaries.forEach { item in
            var item = item.value
            item.register(sectionView: sectionView)
            item.indexPath = .init(row: 0, section: injection.index)
            var viewInjection = SKCRegistrationInjection(index: injection.index)
            item.injection = viewInjection
            viewInjection.add(.reload) { [weak injection] viewInjection in
                injection?.send(.reload)
            }
        }
    }
    
    func prepare(injection: SKCRegistrationSectionInjection,
                 with registrations: [any SKCCellRegistrationProtocol],
                 offset: Int) {
        registrations.enumerated().forEach { item in
            var element = item.element
            element.register(sectionView: sectionView)
            element.indexPath = .init(row: offset + item.offset, section: injection.index)
            var viewInjection = SKCRegistrationInjection(index: item.offset)
            element.injection = viewInjection
            viewInjection.add(.reload) { [weak injection] viewInjection in
                injection?.reload(cell: viewInjection.index)
            }
            viewInjection.add(.delete) { [weak self, weak element] _ in
                guard let self = self, let element = element else { return }
                self.delete(cell: element)
            }
        }
    }
    
}
