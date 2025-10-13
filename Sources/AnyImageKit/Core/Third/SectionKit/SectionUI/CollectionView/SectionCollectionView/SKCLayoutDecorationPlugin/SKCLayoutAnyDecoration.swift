//
//  File.swift
//  
//
//  Created by linhey on 2024/3/17.
//

import UIKit

public struct SKCLayoutAnyDecoration {
    
    public let wrapperValue: any SKCLayoutDecorationPlugin
    
    public init<View: SKCDecorationView>(_ section: SKCSectionActionProtocol,
                                         viewType: View.Type,
                                         zIndex: Int = -1,
                                         layout: [SKCollectionFlowLayout.DecorationLayout] = [.header, .cells, .footer],
                                         insets: UIEdgeInsets = .zero) {
        self.init(sectionIndex: .init(section),
                  viewType: viewType,
                  zIndex: zIndex,
                  layout: layout,
                  insets: insets)
    }
    
    public init<View: SKCDecorationView>(section: SKCSectionProtocol,
                                         viewType: View.Type,
                                         mode: [SKCLayoutDecoration.Mode] = [.visibleView],
                                         zIndex: Int = -1,
                                         layout: [SKCLayoutDecoration.Layout] = [.header, .cells, .footer],
                                         insets: UIEdgeInsets = .zero) {
        wrapperValue = SKCLayoutDecoration.Entity<View>(from: .init(index: .init(section), modes: mode, layout: layout),
                                                        to: nil,
                                                        insets: insets,
                                                        zIndex: zIndex)
    }
    
    public init<View: SKCDecorationView>(sectionIndex: SKBindingKey<Int>,
                                         viewType: View.Type,
                                         modes: [SKCLayoutDecoration.Mode] = [.visibleView],
                                         zIndex: Int = -1,
                                         layout: [SKCLayoutDecoration.Layout] = [.header, .cells, .footer],
                                         insets: UIEdgeInsets = .zero) {
        wrapperValue = SKCLayoutDecoration.Entity<View>(from: .init(index: sectionIndex, modes: modes, layout: layout),
                                                        to: nil,
                                                        insets: insets,
                                                        zIndex: zIndex)
    }
    
    public init<View: SKCDecorationView>(from: SKCLayoutDecoration.Item, to: SKCLayoutDecoration.Item?,
                                         viewType: View.Type,
                                         zIndex: Int = -1,
                                         insets: UIEdgeInsets = .zero) {
        wrapperValue = SKCLayoutDecoration.Entity<View>(from: from,
                                                        to: to,
                                                        insets: insets,
                                                        zIndex: zIndex)
    }
}
