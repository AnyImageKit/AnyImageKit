//
//  ConfigurableProtocol.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/7/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol ConfigurableModelProtocol {
    associatedtype Model
    func config(_ model: Model)
    static func validate(_ model: Model) -> Bool
}

extension ConfigurableModelProtocol {
    
    static func validate(_ model: Model) -> Bool { true }
}

extension ConfigurableModelProtocol where Model == Void {
    
    func config(_ model: Model) { }
}

protocol ConfigurableView: UIView, ConfigurableModelProtocol {
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize
}

extension ConfigurableView {
    
    static func preferredSize(model: Model?) -> CGSize {
        Self.preferredSize(limit: .zero, model: model)
    }

    static func preferredHeight(width: CGFloat, model: Model?) -> CGFloat {
        Self.preferredSize(limit: .init(width: width, height: 0), model: model).height
    }

    static func preferredWidth(height: CGFloat, model: Model?) -> CGFloat {
        Self.preferredSize(limit: .init(width: 0, height: height), model: model).width
    }

    func preferredSize(model: Model?) -> CGSize {
        Self.preferredSize(limit: .zero, model: model)
    }

    func preferredHeight(width: CGFloat, model: Model?) -> CGFloat {
        Self.preferredSize(limit: .init(width: width, height: 0), model: model).height
    }

    func preferredWidth(height: CGFloat, model: Model?) -> CGFloat {
        Self.preferredSize(limit: .init(width: 0, height: height), model: model).width
    }
}

extension ConfigurableView where Model == Void {

    static func preferredSize() -> CGSize {
        Self.preferredSize(limit: .zero, model: nil)
    }

    static func preferredHeight(width: CGFloat) -> CGFloat {
        Self.preferredSize(limit: .init(width: width, height: 0), model: nil).height
    }

    static func preferredWidth(height: CGFloat) -> CGFloat {
        Self.preferredSize(limit: .init(width: 0, height: height), model: nil).width
    }

    func preferredSize() -> CGSize {
        Self.preferredSize(limit: .zero, model: nil)
    }

    static func preferredSize(limit size: CGSize) -> CGSize {
        Self.preferredSize(limit: size, model: nil)
    }

    func preferredHeight(width: CGFloat) -> CGFloat {
        Self.preferredSize(limit: .init(width: width, height: 0), model: nil).height
    }

    func preferredWidth(height: CGFloat) -> CGFloat {
        Self.preferredSize(limit: .init(width: 0, height: height), model: nil).width
    }
}
