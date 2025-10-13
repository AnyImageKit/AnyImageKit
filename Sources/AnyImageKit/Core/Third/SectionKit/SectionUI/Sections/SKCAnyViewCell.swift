//
//  AnyViewCell.swift
//  iDxyer
//
//  Created by linhey on 4/16/25.
//  Copyright © 2025 dxy.cn. All rights reserved.
//

import Foundation
import UIKit

public final class SKCAnyViewCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    public struct Layout {
        
        public let value: (_ view: UIView, _ contentView: UIView) -> Void
        
        public init(value: @escaping (_: UIView, _: UIView) -> Void) {
            self.value = value
        }
        
        public static func fill() -> Layout {
            .init { view, contentView in
                view.translatesAutoresizingMaskIntoConstraints = false
                [
                    view.topAnchor.constraint(equalTo: contentView.topAnchor),
                    view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ].forEach { $0.isActive = true }
            }
        }
    }
    
    public struct PreferredSize {
        
        public let value: (_ limit: CGSize, _ model: Model?) -> CGSize
        
        public init(value: @escaping (_: CGSize, _: Model?) -> CGSize) {
            self.value = value
        }
        
        public static func height(_ value: CGFloat) -> PreferredSize {
            .init { limit, _ in
                return .init(width: limit.width, height: value)
            }
        }
        
    }
    
    public struct Model {
        public let view: UIView?
        public let size: PreferredSize
        public let layout: Layout
        
        public init(view: UIView?, size: PreferredSize, layout: Layout) {
            self.view = view
            self.size = size
            self.layout = layout
        }
    }
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        model?.size.value(size, model) ?? .zero
    }
    
    public var model: Model?
    
    public func config(_ model: Model) {
        self.model?.view?.removeFromSuperview()
        model.view?.removeFromSuperview()
        self.model = model
        guard let view = model.view else {
            return
        }
        self.contentView.addSubview(view)
        model.layout.value(view, contentView)
    }
    
}
