//
//  Core+UIViewController.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2022/11/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// 获取当前显示控制器
    static var current: UIViewController? {
        
        func find(rawVC: UIViewController) -> UIViewController {
            switch rawVC {
            case let vc where vc.presentedViewController != nil:
                return find(rawVC: vc.presentedViewController!)
            case let nav as UINavigationController:
                guard let vc = nav.visibleViewController else { return rawVC }
                return find(rawVC: vc)
            case let tab as UITabBarController:
                guard let vc = tab.selectedViewController else { return rawVC }
                return find(rawVC: vc)
            default:
                return rawVC
            }
        }
        
        guard let controller = ScreenHelper.keyWindow?.rootViewController else {
            return nil
        }
        
        return find(rawVC: controller)
    }
}
