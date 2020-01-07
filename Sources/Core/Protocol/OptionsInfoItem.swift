//
//  OptionsInfoItem.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol OptionsInfoItem: EnumCaseEquatable { }

extension Array where Element: OptionsInfoItem {
    
    public mutating func update(_ element: Element) {
        self.remove(element)
        self.append(element)
    }
    
    public mutating func remove(_ element: Element) {
        if let idx = (self.firstIndex{ $0 ~== element }) {
            self.remove(at: idx)
        }
    }
}
