//
//  Asset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

public protocol Asset: IdentifiableResource {
    
    var mediaType: MediaType { get }
    var image: UIImage { get }
}
