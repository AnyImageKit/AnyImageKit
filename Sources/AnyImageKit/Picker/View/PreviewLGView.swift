//
//  PreviewLGView.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/11/11.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//


import UIKit

final class PreviewLGView: UIView {
    
//    var backButton = UIBarButtonItem()
    private(set) lazy var backButton: UIButton = {
        guard #available(iOS 26.0, *) else {
            return UIButton()
        }
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.clearGlass()
        config.image = UIImage(systemName: "chevron.backward")
//        config.preferredSymbolConfigurationForImage = .init(pointSize: 12, weight: .medium)
        view.configuration = config
//        view.showsMenuAsPrimaryAction = true
        return view
    }()
    var selecteButton = UIBarButtonItem()
    
}
