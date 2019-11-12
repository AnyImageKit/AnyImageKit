//
//  ImagePickerController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImagePickerControllerDelegate: class {
    
    func imagePicker(_ picker: ImagePickerController, didSelect assets: [Asset], useOriginalImage: Bool)
}

open class ImagePickerController: UINavigationController {
    
    open weak var pickerDelegate: ImagePickerControllerDelegate?
    
    open var tag: Int = 0
    
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
    
    private var containerSize: CGSize = .zero
    private var hasOverrideGeneratingDeviceOrientation = false
    private var hiddenStatusBar = false
    private var didFinishSelect = false
    internal var lock: NSLock = NSLock()
    
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
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newSize = view.frame.size
        if containerSize != .zero, containerSize != newSize {
            _print("ImagePickerController container size did change, new size = \(newSize)")
            NotificationCenter.default.post(name: .containerSizeDidChange, object: nil, userInfo: [containerSizeKey: newSize])
        }
        containerSize = newSize
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        endGeneratingDeviceOrientationNotifications()
        PhotoManager.shared.clearAll()
    }
}

// MARK: - Private function
extension ImagePickerController {
    
    private func checkData() {
        showWaitHUD()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let manager = PhotoManager.shared
            let assets = manager.selectdAssets
            var isReady = true
            for asset in assets {
                if !asset.isReady {
                    isReady = false
                    PhotoManager.shared.syncAsset(asset, postNotification: true)
                }
            }
            if !isReady { return }
            self.resizeImagesIfNeeded(assets)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                hideHUD()
                self.finishSelect()
            }
        }
    }
    
    private func finishSelect() {
        lock.lock()
        if didFinishSelect {
            didFinishSelect = false
            let manager = PhotoManager.shared
            pickerDelegate?.imagePicker(self, didSelect: manager.selectdAssets, useOriginalImage: manager.useOriginalImage)
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
        lock.unlock()
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
        checkData()
    }
}

// MARK: - Notification
extension ImagePickerController {
    
    private func beginGeneratingDeviceOrientationNotifications() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            hasOverrideGeneratingDeviceOrientation = true
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
    }
    
    private func endGeneratingDeviceOrientationNotifications() {
        if UIDevice.current.isGeneratingDeviceOrientationNotifications && hasOverrideGeneratingDeviceOrientation {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
    
    private func addNotification() {
        beginGeneratingDeviceOrientationNotifications()
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
        if let message = notification.object as? String {
            showMessageHUD(message)
        } else {
            checkData()
        }
    }
}

extension Notification.Name {
    
    static let setupStatusBarHidden: Notification.Name = Notification.Name("org.AnyImageProject.AnyImageKit.setupStatusBar")
    static let containerSizeDidChange: Notification.Name = Notification.Name("org.AnyImageProject.AnyImageKit.containerSizeDidChange")
}

let containerSizeKey: String = "org.AnyImageProject.AnyImageKit.containerSizeKey"
