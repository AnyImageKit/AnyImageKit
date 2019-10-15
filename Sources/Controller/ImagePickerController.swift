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
    
    func imagePicker(_ picker: ImagePickerController, didSelect assets: [Asset], isOriginal: Bool)
}

open class ImagePickerController: UINavigationController {
    
    open weak var pickerDelegate: ImagePickerControllerDelegate?
    
    private var hiddenStatusBar = false
    
    public var config: Config {
        return PhotoManager.shared.config
    }
    
    open override var prefersStatusBarHidden: Bool {
        return hiddenStatusBar
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        switch PhotoManager.shared.config.theme.style {
        case .light:
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        case .dark:
            return .lightContent
        case .auto:
            return .default
        }
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    required public init(config: Config = .init(), delegate: ImagePickerControllerDelegate) {
        PhotoManager.shared.config = config
        let rootViewController = AssetPickerViewController()
        super.init(rootViewController: rootViewController)
        self.pickerDelegate = delegate
        
        navigationBar.barTintColor = config.theme.backgroundColor
        navigationBar.tintColor = config.theme.textColor
        addNotification()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit")
        PhotoManager.shared.clearAll()
    }
}

// MARK: - Notification
extension ImagePickerController {
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupStatusBarHidden(notification:)), name: .setupStatusBarHidden, object: nil)
    }
    
    @objc private func setupStatusBarHidden(notification: Notification) {
        if let hidden = notification.object as? Bool {
            hiddenStatusBar = hidden
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
}

extension Notification.Name {
    
    static let setupStatusBarHidden: Notification.Name = Notification.Name("com.anotheren.AnyImagePicker.setupStatusBar")
    
}
