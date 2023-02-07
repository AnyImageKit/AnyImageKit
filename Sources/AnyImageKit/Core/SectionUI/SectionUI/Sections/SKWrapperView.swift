//
//  File.swift
//
//
//  Created by linhey on 2022/10/5.
//

import UIKit

open class SKWrapperView<Content: UIView, UserInfo>: UIView, SKLoadViewProtocol, SKConfigurableView {

    public struct Model {
        
        public let userInfo: UserInfo
        public let insets: UIEdgeInsets
        public let size: (_ limit: CGSize) -> CGSize
        public let style: (_ view: Content) -> Void
        
        public init(userInfo: UserInfo,
                    insets: UIEdgeInsets,
                    size: @escaping (_ limit: CGSize) -> CGSize,
                    style: @escaping (Content) -> Void) {
            self.userInfo = userInfo
            self.insets = insets
            self.size = size
            self.style = style
        }
    }
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model else { return .zero }
        let width = size.width - model.insets.left - model.insets.right
        let height = size.height - model.insets.top - model.insets.bottom
        return model.size(.init(width: width, height: height))
    }
        
    public func config(_ model: Model) {
        model.style(content)
        left.constant = model.insets.left
        right.constant = -model.insets.right
        top.constant = model.insets.top
        bottom.constant = -model.insets.bottom
    }
    
    private lazy var content = Content()
    private lazy var left   = content.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
    private lazy var right  = content.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
    private lazy var top    = content.topAnchor.constraint(equalTo: topAnchor, constant: 0)
    private lazy var bottom = content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        left.isActive = true
        right.isActive = true
        top.isActive = true
        bottom.isActive = true
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
