//
//  AnyImageLoader.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol AnyImageLoader: AnyObject {
    
    func startRequest(id: Int, identifier: String)
    func endRequest(id: Int, identifier: String)
}

final class DefaultImageLoader: AnyImageLoader {
    
    
    func startRequest(id: Int, identifier: String) {
        
    }
    
    func endRequest(id: Int, identifier: String) {
        
    }
}
