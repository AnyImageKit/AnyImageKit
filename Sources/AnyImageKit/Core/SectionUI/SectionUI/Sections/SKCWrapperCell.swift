//
//  SectionUnitViewWrapper.swift
//  DUI
//
//  Created by linhey on 2022/9/20.
//

import UIKit

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func wrapperToCollectionCell() -> SKCWrapperCell<Self>.Type {
        return SKCWrapperCell<Self>.self
    }
    
}

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func wrapperToCollectionReusableView() -> SKCWrapperReusableView<Self>.Type {
        return SKCWrapperReusableView<Self>.self
    }
    
}

public class SKCWrapperCell<View: SKConfigurableView & SKLoadViewProtocol>: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {
    
    public static func preferredSize(limit size: CGSize, model: View.Model?) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
    public typealias Model = View.Model
    
    public func config(_ model: View.Model) {
        wrappedView.config(model)
    }
    
    public private(set) lazy var wrappedView = View()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize(contentView: contentView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
        initialize(contentView: contentView)
    }
    
    private func initialize(contentView: UIView) {
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrappedView)
        [wrappedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
         wrappedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
         wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
         wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)].forEach { constraint in
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
    }
    
}

public class SKCWrapperReusableView<View: SKConfigurableView & SKLoadViewProtocol>: UICollectionReusableView, SKConfigurableView, SKLoadViewProtocol {
    
    public static func preferredSize(limit size: CGSize, model: View.Model?) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
    public typealias Model = View.Model
    
    
    public func config(_ model: View.Model) {
        wrappedView.config(model)
    }
    
    public private(set) lazy var wrappedView = View()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize(contentView: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize(contentView: self)
    }
    
    private func initialize(contentView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrappedView)
        [wrappedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
         wrappedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
         wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
         wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)].forEach { constraint in
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
    }
    
}

