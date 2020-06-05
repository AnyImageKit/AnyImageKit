//
//  RowTypeRule.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol RowTypeRule {
    var title: String { get }
    var options: String { get }
    var defaultValue: String { get }
    var indexPath: IndexPath { get }
    
    func getFunction<T: UIViewController>(_ controller: T) -> (() -> Void)
}

extension RowTypeRule {
    
    func getFunction<T: UIViewController>(_ controller: T) -> (() -> Void) {
        return { }
    }
}
