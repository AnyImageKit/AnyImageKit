//
//  CheckableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/15.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

protocol CheckableResource {
    
    associatedtype Resource: IdentifiableResource
    
    var checker: AssetChecker<Resource> { get }
}
