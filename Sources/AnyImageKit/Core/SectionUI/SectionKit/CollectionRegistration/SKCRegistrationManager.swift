//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public class SKCRegistrationManager {
    
    public private(set) lazy var sections: [SKCRegistrationSectionProtocol] = []
    public private(set) lazy var sectionsStore: [Int: SKCRegistrationSectionProtocol] = [:]
    
    public var scrollObserver: SKScrollViewDelegate { delegate }
    public private(set) lazy var prefetching = SKCViewDataSourcePrefetching { [weak self] section in
        self?.safe(section: section)
    }
    
    public private(set) var sectionView: UICollectionView?

    /// difference 计算时, 新的数据将放入 waitSections 中等待下一次 difference 计算
    private var differenceLock = false
    private var waitSections: [SKCRegistrationSectionProtocol]?
    
    private lazy var delegate = SKCViewDelegateFlowLayout { [weak self] indexPath in
        return self?.safe(section: indexPath.section)
    } endDisplaySection: { [weak self] indexPath in
        guard let self = self else { return nil }
        return self.sectionsStore[indexPath.section]
    } sections: { [weak self] in
        return self?.sections ?? []
    }
    
    private lazy var dataSource = SKCDataSource { [weak self] indexPath in
        self?.safe(section: indexPath.section)
    } sections: { [weak self] in
        self?.sections ?? []
    }
        
    private lazy var context = SKCSectionInjection.SectionViewProvider(sectionView)
    
    public init(sectionView: UICollectionView) {
        self.sectionView = sectionView
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        sectionView.prefetchDataSource = prefetching
    }
    
}

public extension SKCRegistrationManager {
    
    func insert(_ input: SKCRegistrationSectionProtocol, at: Int) {
        insert([input], at: at)
    }
    func insert(_ input: [any SKCRegistrationSectionProtocol], at: Int) {
        var sections = (waitSections ?? sections)
        sections.insert(contentsOf: input, at: at)
        reload(sections)
    }
    
    func insert(_ input: SKCRegistrationSectionProtocol, before: SKCRegistrationSectionProtocol) {
        insert([input], before: before)
    }
    func insert(_ input: [any SKCRegistrationSectionProtocol], before: SKCRegistrationSectionProtocol) {
        guard let index = (waitSections ?? sections).firstIndex(where: { $0 === before }) else {
            return
        }
        insert(input, at: index)
    }
    
    func insert(_ input: SKCRegistrationSectionProtocol, after: SKCRegistrationSectionProtocol) {
        insert([input], after: after)
    }
    func insert(_ input: [any SKCRegistrationSectionProtocol], after: SKCRegistrationSectionProtocol) {
        guard let index = (waitSections ?? sections).firstIndex(where: { $0 === after }) else {
            return
        }
        insert(input, at: index + 1)
    }
    
    func append(_ input: SKCRegistrationSectionProtocol) { append([input]) }
    func append(_ input: [any SKCRegistrationSectionProtocol]) { reload((waitSections ?? sections) + input) }
    
    func remove(_ input: [any SKCRegistrationSectionProtocol]) {
        let IDs = input.map({ ObjectIdentifier($0) })
        let sections = (waitSections ?? sections).filter({ !IDs.contains(ObjectIdentifier($0)) })
        difference(sections)
    }
    func remove(_ input: SKCRegistrationSectionProtocol) { remove([input]) }
    
    @MainActor
    private func pick(_ block: () -> Void) async {
        await withUnsafeContinuation { continuation in
            sectionView?.performBatchUpdates {
                block()
            } completion: { _ in
                continuation.resume()
            }
        }
    }
    
}

public extension SKCRegistrationManager {
    
    func reload(_ sections: [any SKCRegistrationSectionProtocol]) {
        difference(sections)
    }
    
    func reload(@SectionArrayResultBuilder<any SKCRegistrationSectionProtocol> _ builder: () -> [any SKCRegistrationSectionProtocol]) {
        reload(builder())
    }
    
    func reload(_ section: any SKCRegistrationSectionProtocol) {
        reload([section])
    }
    
    func reload(@SKCRegistrationSectionBuilder builder: (() -> [SKCRegistrationSectionBuilderStore])) {
        reload(SKCRegistrationSection(builder: builder))
    }
    
}

private extension SKCRegistrationManager {
    
    func difference(_ sections: [any SKCRegistrationSectionProtocol]) {
        
        guard !differenceLock else {
            waitSections = sections
            return
        }
        differenceLock = true
        
        Task { @MainActor in
            defer {
                differenceLock = false
                if let section = waitSections {
                    reload(section)
                    waitSections = nil
                }
            }
            guard let sectionView = sectionView else {
                return
            }
            
            self.sectionsStore.removeAll()
            
            /// 存储上一次 context 待函数结束自动释放
            _ = context
            context = .init(sectionView)
            
            sections.enumerated().forEach { element in
                let section = element.element
                let injection = SKCRegistrationSectionInjection(index: element.offset, sectionView: context)
                injection.add(action: .reload) { injection in
                    injection.sectionView?.reloadData()
                }
                .add(action: .delete) { injection in
                    injection.sectionView?.deleteSections(.init(integer: injection.index))
                }
                section.registrationSectionInjection = injection
                section.prepare(injection: injection)
                section.config(sectionView: sectionView)
            }
            
            if self.sections.isEmpty {
                self.sections = sections
                self.sectionView?.reloadData()
                return
            }
            
            let result = sections.difference(from: self.sections) { lhs, rhs in
                return lhs === rhs
            }
            
            if !result.removals.isEmpty {
                var indexSet = [Int]()
                for changed in result.removals.reversed() {
                    switch changed {
                    case let .remove(offset: offset, element: element, associatedWith: _):
                        if let index = element.sectionInjection?.index {
                            self.sectionsStore[index] = element
                        }
                        indexSet.append(offset)
                    default:
                        assertionFailure()
                    }
                }
                await pick {
                    indexSet.forEach { offset in
                        self.sections.remove(at: offset)
                    }
                    sectionView.deleteSections(.init(indexSet))
                }
            }
            
            self.sections = sections
            
            if !result.insertions.isEmpty {
                var insertIndexSet = IndexSet()
                for changed in result.insertions {
                    switch changed {
                    case let .insert(offset: offset, element: _, associatedWith: _):
                        insertIndexSet.update(with: offset)
                    default:
                        assertionFailure()
                    }
                }
                
                await pick {
                    sectionView.insertSections(insertIndexSet)
                }
            }
        }
    }
    
}

private extension SKCRegistrationManager {
    
    func safe<T>(section: Int) -> T? {
        guard sections.indices.contains(section) else {
            return nil
        }
        return sections[section] as? T
    }
    
}
