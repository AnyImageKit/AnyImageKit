//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit
import Combine

public class SKCSectionInjection {
    
    public struct Configuration {
        /// 转换类型
        /// 将 reloadSection 操作替换为 reloadData 操作:
        //        SKCSectionInjection.configuration.mapAction = { action in
        //            if action == .reload {
        //                return .reload
        //            }
        //            return action
        //        }
       public var mapAction: (_ action: Action) -> Action = { $0 }
        
       public mutating func setMapAction(_ block: @escaping (_ action: Action) -> Action) {
            self.mapAction = block
        }
    }
    
    public struct Action: OptionSet, Hashable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    class SectionViewProvider {
        
        weak var sectionView: UICollectionView?
        
        init(_ sectionView: UICollectionView?) {
            self.sectionView = sectionView
        }
    }
    
    public static var configuration = Configuration()
    public var configuration = SKCSectionInjection.configuration
    public let index: Int
    public var sectionView: UICollectionView? { sectionViewProvider.sectionView }
    
    var sectionViewProvider: SectionViewProvider
    private var events: [Action: (SKCSectionInjection) -> Void] = [:]
    
    init(index: Int, sectionView: SectionViewProvider) {
        self.sectionViewProvider = sectionView
        self.index = index
    }
    
}

public extension SKCSectionInjection.Action {
    
    static let reload     = Self(rawValue: 1 << 1)
    static let delete     = Self(rawValue: 1 << 2)
    static let reloadData = Self(rawValue: 1 << 3)
    
}

public extension SKCSectionInjection {
    
    func delete() {
        events[configuration.mapAction(.delete)]?(self)
    }
    
    func reload() {
        events[configuration.mapAction(.reload)]?(self)
    }
    
    func reloadData() {
        events[configuration.mapAction(.reloadData)]?(self)
    }
    
    func insert(cell rows: Int...) {
        delete(cell: rows)
    }
    
    func insert(cell rows: [Int]) {
        sectionView?.insertItems(at: rows.map({ IndexPath(row: $0, section: index) }))
    }
    
    func delete(cell rows: Int...) {
        delete(cell: rows)
    }
    
    func delete(cell rows: [Int]) {
        sectionView?.deleteItems(at: rows.map({ IndexPath(row: $0, section: index) }))
    }
    
    func reload(cell rows: [Int]) {
        guard !rows.isEmpty else {
            return
        }
        sectionView?.reloadItems(at: rows.map({ IndexPath(row: $0, section: index) }))
    }
    
    func reload(cell rows: Int...) {
        reload(cell: rows)
    }
    
    func reload(cell rows: Range<Int>) {
        reload(cell: Array(rows))
    }
    
    @discardableResult
    func add(action: Action, event: @escaping (_ injection: SKCSectionInjection) -> Void) -> Self {
        self.events[action] = event
        return self
    }
    
    func send(_ action: Action) {
        guard sectionView != nil else {
            return
        }
        guard let event = events[action] else {
            assertionFailure()
            return
        }
        event(self)
    }
    
}
