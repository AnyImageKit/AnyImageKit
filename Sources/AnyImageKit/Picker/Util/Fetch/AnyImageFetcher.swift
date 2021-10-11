//
//  AnyImageFetcher.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final public class AnyImageFetcher<Resource: IdentifiableResource> {
    
    var thumbnailSize: CGSize = .init(width: 200, height: 200)
    var previewSize: CGSize = .init(width: 1200, height: 1200)
    
    func startRequest(id: Int, identifier: String) {
        _print("🕛 Start Request [\(identifier)]<\(id)>")
    }
    
    func endRequest(id: Int, identifier: String) {
        _print("✅ End Request [\(identifier)]<\(id)>")
    }
}
