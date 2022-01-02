//
//  Ex+UITableViewCell.swift
//  Example
//
//  Created by 刘栋 on 2020/11/4.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
