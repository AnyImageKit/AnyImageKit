//
//  ImagePickerController.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImagePickerControllerDelegate: class {
    
    func imagePicker(_ picker: ImagePickerController)
}

open class ImagePickerController: UINavigationController {
    
    open weak var pickerDelegate: ImagePickerControllerDelegate?
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public init(maxCount: UInt = 1, columnNumber: UInt = 4, delegate: ImagePickerControllerDelegate) {
        let rootViewController = AssetPickerViewController()
        super.init(rootViewController: rootViewController)
        self.pickerDelegate = delegate
        modalPresentationStyle = .fullScreen
        navigationBar.barTintColor = UIColor.wechat_dark_background
        navigationBar.tintColor = UIColor.wechat_dark_text
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
