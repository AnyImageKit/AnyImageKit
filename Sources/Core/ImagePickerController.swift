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
    
    public var config: Config {
        return PhotoManager.shared.config
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    public init(config: Config = .init(), delegate: ImagePickerControllerDelegate) {
        PhotoManager.shared.config = config
        let rootViewController = AssetPickerViewController()
        super.init(rootViewController: rootViewController)
        self.pickerDelegate = delegate
        
        navigationBar.barTintColor = config.theme.backgroundColor
        navigationBar.tintColor = config.theme.textColor
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
