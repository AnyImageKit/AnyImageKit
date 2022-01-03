//
//  RowTypeRule.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol HomeRowTypeRule {
    var title: String { get }
    var controller: UIViewController { get }
}

protocol RowTypeRule {
    var title: String { get }
    var options: String { get }
    var defaultValue: String { get }
    
    func getFunction<T: UIViewController>(_ controller: T) -> ((IndexPath) -> Void)
}

extension RowTypeRule {
    
    func getFunction<T: UIViewController>(_ controller: T) -> ((IndexPath) -> Void) {
        return { _ in  }
    }
}
