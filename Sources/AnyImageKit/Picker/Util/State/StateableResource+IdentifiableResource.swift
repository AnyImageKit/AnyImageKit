//
//  StateableResource+IdentifiableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/13.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension StateableResource where Self: IdentifiableResource {
    
    var stateIdentifier: String {
        return identifier
    }
}
