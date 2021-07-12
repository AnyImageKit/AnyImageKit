//
//  LoadableResource+IdentifiableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension LoadableResource where Self: IdentifiableResource {
    
    var loadIdentifier: String {
        return identifier
    }
}