//
//  File.swift
//  
//
//  Created by linhey on 2024/3/17.
//

import UIKit

public struct SKCLayoutDecoration {
    
    public struct Context<View: SKCDecorationView> {
        public let type: SKCSupplementaryActionType
        public let kind: SKSupplementaryKind
        public let indexPath: IndexPath
        public let view: View
    }
    
    public enum Layout {
        case header
        case cells
        case footer
    }
    
    public enum Mode {
        /// 按照可视视图区域计算
        case visibleView
        /// 按照原始的 section 区域计算
        case section
        /// 没有头尾时用sectioninset填充
        case useSectionInsetWhenNotExist(_ layout: [Layout] = [.header, .footer])
        
    }
    
    public struct Item {
        
        public var index: SKBindingKey<Int>
        public var layout: [Layout]
        public var modes: [Mode]
        
        public init(index: SKBindingKey<Int>,
                    modes: [Mode] = [.visibleView],
                    layout: [Layout] = [.header, .cells, .footer]) {
            self.index  = index
            self.modes  = modes
            self.layout = layout
            
#if DEBUG
            var useSectionInsetWhenNotExist = false
            var visibleViewOrSection = false
            self.modes.forEach({ mode in
                switch mode {
                case .visibleView, .section:
                    visibleViewOrSection = true
                case .useSectionInsetWhenNotExist:
                    useSectionInsetWhenNotExist = true
                }
            })
            
            if useSectionInsetWhenNotExist, visibleViewOrSection == false {
                assertionFailure("需要指定 .visibleView 或者 .section")
            }
#endif
        }
        
        public init(_ section: SKCSectionProtocol,
                    modes: [Mode] = [.visibleView],
                    layout: [Layout] = [.header, .cells, .footer]) {
            self.init(index: .init(section), modes: modes, layout: layout)
        }
    }
    
    public class Entity<Target: SKCDecorationView>: SKCLayoutDecorationPlugin {
        
        public typealias View = Target
        public var id: String
        public var from: Item
        public var to: Item?
        public var viewType: View.Type
        public var insets: UIEdgeInsets
        public var index: Int?
        public var zIndex: Int?
        public var actions: [SKCSupplementaryActionType : [ActionBlock]] = [:]
        
        public init(id: String = UUID().uuidString,
                    from: Item,
                    to: Item? = nil,
                    insets: UIEdgeInsets = .zero,
                    zIndex: Int? = nil,
                    actions: [SKCSupplementaryActionType : [ActionBlock]] = [:]) {
            self.id = id
            self.from = from
            self.to = to
            self.viewType = View.self
            self.insets = insets
            self.zIndex = zIndex
            self.actions = actions
        }
        
    }
    
    
}
