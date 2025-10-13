//
//  File.swift
//  
//
//  Created by linhey on 2024/2/26.
//

import UIKit

public struct SKUIContextMenuResult: ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = SKUIAction
    
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
    
    public init(arrayLiteral elements: UIAction...) {
        self.init(elements)
    }
    
    public init(arrayLiteral elements: SKUIAction...) {
        self.init(elements)
    }

    public init(_ menu: UIMenu) {
        self.init(configuration: .init(actionProvider: { suggest in
            return menu
        }))
    }
    
    public init(_ elements: [UIAction]) {
        self.init(UIMenu(children: elements))
    }
    
    public init(_ elements: [SKUIAction]) {
        self.init(UIMenu(children: elements))
    }
    
}
