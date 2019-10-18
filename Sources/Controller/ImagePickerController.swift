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
    
    func imagePicker(_ picker: ImagePickerController, didSelect assets: [Asset], useOriginalImage: Bool)
}

open class ImagePickerController: UINavigationController {
    
    open weak var pickerDelegate: ImagePickerControllerDelegate?
    
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
    
    private var hiddenStatusBar = false
    private var didFinishSelect = false
    internal var hudWindow: UIWindow?
    internal var hud: HUDViewController = HUDViewController()
    
    required public init(config: Config = .init(), delegate: ImagePickerControllerDelegate) {
        PhotoManager.shared.config = config
        let rootViewController = AssetPickerViewController()
        super.init(rootViewController: rootViewController)
        self.pickerDelegate = delegate
        rootViewController.delegate = self
        
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
        PhotoManager.shared.clearAll()
    }
}

// MARK: - Private function
extension ImagePickerController {
    
    private func finishSelect() {
        showWaitHUD()
        let manager = PhotoManager.shared
        let assets = manager.selectdAssets
        var isReady = true
        for asset in assets {
            if !asset.isReady {
                isReady = false
                PhotoManager.shared.syncAsset(asset)
            }
        }
        if !isReady { return }
        didFinishSelect = false
        resizeImagesIfNeeded(assets)
        hideHUD()
        
        pickerDelegate?.imagePicker(self, didSelect: assets, useOriginalImage: manager.useOriginalImage)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func resizeImagesIfNeeded(_ assets: [Asset]) {
        if !PhotoManager.shared.useOriginalImage {
            let limitSize = CGSize(width: PhotoManager.shared.config.photoMaxWidth,
                                   height: PhotoManager.shared.config.photoMaxWidth)
            for asset in assets {
                if let image = asset._image, image.size != .zero  {
                    let resizedImage = UIImage.resize(from: image, limitSize: limitSize, isExact: true)
                    asset._image = resizedImage
                }
            }
        }
    }
}

// MARK: - AssetPickerViewControllerDelegate
extension ImagePickerController: AssetPickerViewControllerDelegate {
    
    func assetPickerControllerDidClickDone(_ controller: AssetPickerViewController) {
        didFinishSelect = true
        finishSelect()
    }
}

// MARK: - Notification
extension ImagePickerController {
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupStatusBarHidden(notification:)), name: .setupStatusBarHidden, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSyncAsset(notification:)), name: .didSyncAsset, object: nil)
    }
    
    @objc private func setupStatusBarHidden(notification: Notification) {
        if let hidden = notification.object as? Bool {
            hiddenStatusBar = hidden
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc private func didSyncAsset(notification: Notification) {
        if didFinishSelect {
            if let message = notification.object as? String {
                showMessageHUD(message)
            } else {
                finishSelect()
            }
        }
    }
}

extension Notification.Name {
    
    static let setupStatusBarHidden: Notification.Name = Notification.Name("com.anotheren.AnyImagePicker.setupStatusBar")
    
}
