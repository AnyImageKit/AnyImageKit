//
//  AssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

protocol AssetCollection: IdentifiableResource {
    
    var localizedTitle: String { get }
    var assets: [Asset] { get }
}
