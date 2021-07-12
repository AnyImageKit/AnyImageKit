//
//  CachableResource+IdentifiableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension CachableResource where Self: IdentifiableResource {
    
    var cahceIdentifier: String {
        return identifier
    }
}