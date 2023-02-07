//
//  Core+UIView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/9/22.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIView {
    
    func getController() -> UIViewController? {
        var view: UIView? = self.superview
        while view != nil {
            if let controller = view?.next as? UIViewController {
                return controller
            }
            view = view?.superview
        }
        return nil
    }
}
