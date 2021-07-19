//
//  AnyImageFetcher.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class AnyImageFetcher<Resource: IdentifiableResource> {
    
    func startRequest(id: Int, identifier: String) {
        _print("🕛 Start Request [\(identifier)]<\(id)>")
    }
    
    func endRequest(id: Int, identifier: String) {
        _print("✅ Start Request [\(identifier)]<\(id)>")
    }
}

extension AnyImageFetcher {
    
    func fetch(resource: Resource, type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion) {
        
    }
}
