//
//  SectionUnitViewWrapper.swift
//  DUI
//
//  Created by linhey on 2022/9/20.
//

#if canImport(UIKit)
import UIKit

public extension SKWrapper where Base: SKConfigurableView & SKLoadViewProtocol {
    
    static func wrapperToCollectionCell() -> SKCWrapperCell<Base>.Type {
        return Base.wrapperToCollectionCell()
    }
    
}

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func wrapperToCollectionCell() -> SKCWrapperCell<Self>.Type {
        return SKCWrapperCell<Self>.self
    }
    
}

open class SKCWrapperCell<View: SKConfigurableView & SKLoadViewProtocol>: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {
    
    public static func preferredSize(limit size: CGSize, model: View.Model?) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
    public typealias Model = View.Model
    
    open func config(_ model: View.Model) {
        wrappedView.config(model)
    }
    
    public private(set) lazy var wrappedView: View = {
        if let nib = View.nib {
            return nib.instantiate(withOwner: nil, options: nil).first as! View
        } else {
            return View()
        }
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize(contentView: contentView)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize(contentView: contentView)
    }
    
    private func initialize(contentView: UIView) {
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        
        [contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
         contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
         contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
         contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)].forEach { constraint in
            constraint.isActive = true
        }
        
        contentView.addSubview(wrappedView)
        [wrappedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
         wrappedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
         wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
         wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)].forEach { constraint in
            constraint.isActive = true
        }
    }
    
}

#endif
