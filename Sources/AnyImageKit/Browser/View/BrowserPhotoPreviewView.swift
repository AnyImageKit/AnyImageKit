//
//  BrowserPhotoPreviewView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/10.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

open class BrowserPhotoPreviewView: BrowserPreviewView {
    
    override init(_ contentSafeAreaLayoutGuide: UILayoutGuide) {
        super.init(contentSafeAreaLayoutGuide)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        imageView.contentMode = .scaleAspectFill
    }
    
}
