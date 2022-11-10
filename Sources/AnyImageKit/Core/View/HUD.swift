//
//  HUD.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2022/11/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

class HUDUtilWrapper<Base> {
    
    let base: Base
    
    init(base: Base) {
        self.base = base
    }
}

protocol HUDUtilCompatible: AnyObject {
    
}

extension HUDUtilCompatible {
    
    var hud: HUDUtilWrapper<Self> {
        return HUDUtilWrapper(base: self)
    }
    
    static var hud: HUDUtilWrapper<Self>.Type {
        return HUDUtilWrapper<Self>.self
    }
    
}

extension UIView: HUDUtilCompatible { }

extension HUDUtilWrapper where Base: UIView {
    
    func show(text: String?) {
        show(text: text ?? "", isEnabled: false)
    }
    
    func show(text: String? = nil, isEnabled: Bool = false) {
        hide()
        let loadingView = LoadingView(frame: base.bounds, text: text ?? "")
        base.addSubview(loadingView)
        loadingView.isUserInteractionEnabled = !isEnabled
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
    }
    
    func hide() {
        base.subviews.reversed().first(where: { $0 is LoadingView })?.removeFromSuperview()
    }
}
