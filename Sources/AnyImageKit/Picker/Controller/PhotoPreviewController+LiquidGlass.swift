//
//  PhotoPreviewController+LiquidGlass.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/11/11.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

extension PhotoPreviewController {
    
    func lgSetupNavigation() {
        guard #available(iOS 26.0, *), !manager.options.designRequiresCompatibility else { return }
        
//        lgView.backButton = UIBarButtonItem(image: manager.options.theme[icon: .backButton], landscapeImagePhone: nil, style: .plain, target: self, action: #selector(backButtonTapped))
//        navigationItem.leftBarButtonItem = lgView.backButton
        
//        lgView.selecteButton = UIBarButtonItem(image: manager.options.theme[icon: .doneButton], landscapeImagePhone: nil, style: .prominent, target: self, action: #selector(lgDoneButtonTapped(_:)))
//        lgView.selecteButton.tintColor = manager.options.theme[color: .primary]
//        lgView.selecteButton.isEnabled = false
//        navigationItem.rightBarButtonItem = .init(customView: navigationBar.selectButton)
        
        
        
    }
}
