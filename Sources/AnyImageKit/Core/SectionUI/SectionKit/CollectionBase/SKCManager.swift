//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

public class SKCManager {
    
    public private(set) lazy var sections: [SKCBaseSectionProtocol] = []
    public private(set) weak var sectionView: UICollectionView?
    
    public var scrollObserver: SKScrollViewDelegate { delegate }
    public private(set) lazy var prefetching = SKCViewDataSourcePrefetching { [weak self] section in
        self?.safe(section: section)
    }
    
    private lazy var endDisplaySections: [Int: SKCBaseSectionProtocol] = [:]
    private lazy var delegate = SKCViewDelegateFlowLayout { [weak self] indexPath in
        self?.safe(section: indexPath.section)
    } endDisplaySection: { [weak self] indexPath in
        self?.safe(section: indexPath.section)
    } sections: { [weak self] in
        return self?.sections.lazy.compactMap({ $0 as? SKCViewDelegateFlowLayoutProtocol }) ?? []
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

public extension SKCManager {
    
    func insert(_ input: SKCBaseSectionProtocol, at: Int) {
        insert([input], at: at)
    }
    func insert(_ input: [SKCBaseSectionProtocol], at: Int) {
        var sections = sections
        sections.insert(contentsOf: input, at: at)
        reload(sections)
    }
    
    func insert(_ input: SKCBaseSectionProtocol, before: SKCBaseSectionProtocol) {
        insert([input], before: before)
    }
    func insert(_ input: [SKCBaseSectionProtocol], before: SKCBaseSectionProtocol) {
        guard let index = sections.firstIndex(where: { $0 === before }) else {
            return
        }
        insert(input, at: index)
    }
    
    func insert(_ input: SKCBaseSectionProtocol, after: SKCBaseSectionProtocol) {
        insert([input], after: after)
    }
    func insert(_ input: [SKCBaseSectionProtocol], after: SKCBaseSectionProtocol) {
        guard let index = sections.firstIndex(where: { $0 === after }) else {
            return
        }
        insert(input, at: index + 1)
    }
    
    func append(_ input: SKCBaseSectionProtocol) { append([input]) }
    func append(_ input: [SKCBaseSectionProtocol]) { reload(sections + input) }
    
    func remove(_ input: SKCBaseSectionProtocol) { remove([input]) }
    func remove(_ input: [SKCBaseSectionProtocol]) {
        let IDs = input.map({ ObjectIdentifier($0) })
        let sections = sections.filter({ !IDs.contains(ObjectIdentifier($0)) })
        reload(sections)
    }
    
}

public extension SKCManager {

    func reload(_ section: SKCBaseSectionProtocol) {
        reload([section])
    }
    
    func reload(_ sections: [SKCBaseSectionProtocol]) {
        guard let sectionView = sectionView else {
            return
        }
        
        context.sectionView = nil
        context = .init(sectionView)
        
        self.endDisplaySections.removeAll()
        self.sections
            .enumerated()
            .forEach({ item in
                self.endDisplaySections[item.offset] = item.element
            })
        
        self.sections = sections.enumerated().map({ element in
            let section = element.element
            section.sectionInjection = .init(index: element.offset, sectionView: context)
                .add(action: .reloadData, event: { injection in
                    injection.sectionView?.reloadData()
                })
                .add(action: .reload, event: { injection in
                    injection.sectionView?.reloadSections(IndexSet(integer: injection.index))
                })
                .add(action: .delete, event: { injection in
                    injection.sectionView?.deleteSections(IndexSet(integer: injection.index))
                })
            section.config(sectionView: sectionView)
            return section
        })
        
        sectionView.reloadData()
    }
    
}


private extension SKCManager {
    
    func safe<T>(section: Int) -> T? {
        guard sections.indices.contains(section) else {
            return nil
        }
        return sections[section] as? T
    }
    
}
