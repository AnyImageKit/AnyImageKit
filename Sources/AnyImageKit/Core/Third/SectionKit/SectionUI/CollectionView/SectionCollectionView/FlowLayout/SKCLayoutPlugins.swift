//
//  File.swift
//
//
//  Created by linhey on 2023/10/12.
//

import UIKit
import Combine

public class SKCPluginLayoutAttributesForElementsForward: Cancellable {
    
    public typealias Fetch = (_ context: Context) -> Void?
    
    public class Context {
        public let layout: UICollectionViewLayout
        public var alwaysInvalidate: Bool?
        public var attributes: [UICollectionViewLayoutAttributes]
        init(layout: UICollectionViewLayout, attributes: [UICollectionViewLayoutAttributes]) {
            self.layout = layout
            self.attributes = attributes
        }
    }
    
    public private(set) var isCanceled: Bool = false
    public let fetch: Fetch
    public var userInfo: [String: Any]?
   
    init(userInfo: [String: Any]? = nil, _ fetch: @escaping Fetch) {
        self.fetch = fetch
        self.userInfo = userInfo
    }
    
    public func cancel() {
        userInfo = nil
        isCanceled = true
    }
}

public struct SKCLayoutPlugins {
    
    public struct FetchAttributes {
        
        let id: String
        public let fetch: () -> [UICollectionViewLayoutAttributes]
        
        public init(id: String = UUID().uuidString,
                    fetch: @escaping () -> [UICollectionViewLayoutAttributes]) {
            self.fetch = fetch
            self.id = id
        }
        
        public init(id: String = UUID().uuidString,
                    fetch: @escaping () -> UICollectionViewLayoutAttributes?) {
            self.fetch = { fetch().map { [$0] } ?? [] }
            self.id = id
        }
    }
    
    /// 布局插件样式
    public enum Mode: Equatable {
        case layoutAttributesForElements([SKCPluginLayoutAttributesForElementsForward])
        case attributes([SKCPluginAdjustAttributes])
        case horizontalAlignment([HorizontalAlignmentPayload])
        /// 水平对齐
        case verticalAlignment([VerticalAlignmentPayload])
        /// fix: header & footer 贴合 cell
        case fixSupplementaryViewInset(FixSupplementaryViewInset.Direction)
        /// fix: header & footer size 与设定值不符
        case fixSupplementaryViewSize
        /// fix: header & footer 调整尺寸, 调整前会重置为真实设定尺寸
        case adjustSupplementaryViewSize(FixSupplementaryViewSize.Condition)
        /// section 装饰视图
        case decorations([any SKCLayoutDecorationPlugin])
        
        var priority: Int {
            switch self {
            case .attributes: return 0
            case .horizontalAlignment: return 100
            case .verticalAlignment: return 100
            case .fixSupplementaryViewSize:    return 1
            case .fixSupplementaryViewInset:   return 2
            case .adjustSupplementaryViewSize: return 3
            case .decorations: return 200
            case .layoutAttributesForElements: return 400
            }
        }
        
        public static func == (lhs: SKCLayoutPlugins.Mode, rhs: SKCLayoutPlugins.Mode) -> Bool {
            lhs.priority == rhs.priority
        }
    }
    
    public var modes: [Mode] = [] {
        didSet {
            let modes = sort(modes: modes)
            guard modes != self.modes else {
                return
            }
            self.modes = modes
        }
    }
    
    public init(modes: [Mode]) {
        self.modes = sort(modes: modes)
    }
    
    func sort(modes: [Mode]) -> [Mode] {
        var set = Set<Int>()
        var newModes = [Mode]()
        
        var attributes = [SKCPluginAdjustAttributes]()
        var verticalAlignments  = [VerticalAlignmentPayload]()
        var horizontalAlignments = [HorizontalAlignmentPayload]()
        var decorations = [any SKCLayoutDecorationPlugin]()
        var layoutAttributesForElements = [SKCPluginLayoutAttributesForElementsForward]()
        /// 优先级冲突去重
        for mode in modes {
            switch mode {
            case .attributes(let list):
                attributes.append(contentsOf: list)
            case .fixSupplementaryViewInset,
                    .fixSupplementaryViewSize,
                    .adjustSupplementaryViewSize:
                if set.insert(mode.priority).inserted {
                    newModes.append(mode)
                } else {
                    assertionFailure("mode冲突: \(newModes.filter { $0.priority == mode.priority })")
                }
            case .verticalAlignment(let array):
                verticalAlignments.append(contentsOf: array)
            case .horizontalAlignment(let array):
                horizontalAlignments.append(contentsOf: array)
            case .decorations(let array):
                decorations.append(contentsOf: array)
            case .layoutAttributesForElements(let array):
                layoutAttributesForElements.append(contentsOf: array.filter({ !$0.isCanceled }))
            }
        }

        if !verticalAlignments.isEmpty {
            newModes.append(.verticalAlignment(verticalAlignments))
        }
        
        if !horizontalAlignments.isEmpty {
            newModes.append(.horizontalAlignment(horizontalAlignments))
        }

        if !decorations.isEmpty {
            newModes.append(.decorations(decorations))
        }
        
        if !attributes.isEmpty {
            newModes.append(.attributes(attributes))
        }
        
        if !layoutAttributesForElements.isEmpty {
            newModes.append(.layoutAttributesForElements(layoutAttributesForElements))
        }
        
        /// mode 重排
        return newModes.sorted(by: { $0.priority < $1.priority })
    }
    
}


public extension SKCLayoutPlugins.Mode {
    
    static var left: SKCLayoutPlugins.Mode {
        .verticalAlignment([.init(alignment: .left, sections: [.all])])
    }
    
    static var right: SKCLayoutPlugins.Mode {
        .verticalAlignment([.init(alignment: .right, sections: [.all])])
    }
    
    static var centerX: SKCLayoutPlugins.Mode {
        .verticalAlignment([.init(alignment: .center, sections: [.all])])
    }
    
    static func attributes(_ item: SKCPluginAdjustAttributes) -> SKCLayoutPlugins.Mode {
        return .attributes([item])
    }

    static func decorations(_ decoration: [SKCLayoutAnyDecoration]) -> SKCLayoutPlugins.Mode {
        .decorations(decoration.map(\.wrapperValue))
    }
    
    static func decorations(_ decoration: SKCLayoutAnyDecoration) -> SKCLayoutPlugins.Mode {
        .decorations([decoration])
    }
    
    static func decorations<View: SKCDecorationView>(_ decoration: [SKCLayoutDecoration.Entity<View>]) -> SKCLayoutPlugins.Mode {
        .decorations(decoration as [any SKCLayoutDecorationPlugin])
    }
    
    static func decorations<View: SKCDecorationView>(_ decoration: SKCLayoutDecoration.Entity<View>) -> SKCLayoutPlugins.Mode {
        .decorations([decoration])
    }
    
    static func decorations(_ decoration: any SKCLayoutDecorationPlugin) -> SKCLayoutPlugins.Mode {
        .decorations([decoration])
    }
    
}
