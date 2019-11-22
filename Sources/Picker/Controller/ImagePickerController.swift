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
    
    func imagePickerDidCancel(_ picker: ImagePickerController)
    func imagePicker(_ picker: ImagePickerController, didFinishPicking assets: [Asset], useOriginalImage: Bool)
}

extension ImagePickerControllerDelegate {
    
    public func imagePickerDidCancel(_ picker: ImagePickerController) {
        picker.dismiss(animated: true)
    }
}

open class ImagePickerController: UINavigationController {
    
    open weak var pickerDelegate: ImagePickerControllerDelegate?
    
    open var tag: Int = 0
    
    public var config: Config {
        return manager.config
    }
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    public var editorConfig: EditorConfig {
        return manager.editorConfig
    }
    #endif
    
    open override var prefersStatusBarHidden: Bool {
        return hiddenStatusBar
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        switch manager.config.theme.style {
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
    private var hasOverrideGeneratingDeviceOrientation: Bool = false
    private var hiddenStatusBar: Bool = false
    private var didFinishSelect: Bool = false
    private let lock: NSLock = .init()
    
    let manager: PickerManager = .init()
    
    required public init(config: Config = .init(), delegate: ImagePickerControllerDelegate) {
        let rootViewController = AssetPickerViewController(manager: manager)
        super.init(rootViewController: rootViewController)
        self.manager.config = config
        self.pickerDelegate = delegate
        rootViewController.delegate = self
        
        navigationBar.barTintColor = config.theme.backgroundColor
        navigationBar.tintColor = config.theme.textColor
        addNotifications()
    }
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    convenience public init(config: Config = .init(), editorConfig: EditorConfig = .init(), delegate: ImagePickerControllerDelegate) {
        self.init(config: config, delegate: delegate)
        self.manager.editorConfig = editorConfig
        self.manager.clearEditorCache()
    }
    #endif
    
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
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        presentingViewController?.dismiss(animated: flag, completion: completion)
    }
    
    deinit {
        removeNotifications()
        #if ANYIMAGEKIT_ENABLE_EDITOR
        manager.clearEditorCache()
        #endif
        manager.clearAll()
    }
}

// MARK: - Private function
extension ImagePickerController {
    
    private func checkData() {
        showWaitHUD()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let assets = self.manager.selectedAssets
            let isReady = self.manager.selectedAssets.filter{ !$0.isReady }.isEmpty
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
            pickerDelegate?.imagePicker(self, didFinishPicking: manager.selectedAssets, useOriginalImage: manager.useOriginalImage)
            manager.selectedAssets.compactMap{ $0._images[.edited] }.forEach{ manager.savePhoto($0) }
        }
        lock.unlock()
    }
    
    private func resizeImagesIfNeeded(_ assets: [Asset]) {
        if !manager.useOriginalImage {
            let limitSize = CGSize(width: manager.config.photoMaxWidth,
                                   height: manager.config.photoMaxWidth)
            for asset in assets {
                if let image = asset._image, image.size != .zero  {
                    let resizedImage = UIImage.resize(from: image, limitSize: limitSize, isExact: true)
                    asset._images[.output] = resizedImage
                }
            }
        }
    }
}

// MARK: - AssetPickerViewControllerDelegate
extension ImagePickerController: AssetPickerViewControllerDelegate {
    
    func assetPickerDidCancel(_ picker: AssetPickerViewController) {
        pickerDelegate?.imagePickerDidCancel(self)
    }
    
    func assetPickerDidFinishPicking(_ controller: AssetPickerViewController) {
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
    
    private func addNotifications() {
        beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(setupStatusBarHidden(_:)), name: .setupStatusBarHidden, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSyncAsset(_:)), name: .didSyncAsset, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
        endGeneratingDeviceOrientationNotifications()
    }
    
    @objc private func setupStatusBarHidden(_ sender: Notification) {
        if let hidden = sender.object as? Bool {
            hiddenStatusBar = hidden
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc private func didSyncAsset(_ sender: Notification) {
        if didFinishSelect {
            if let message = sender.object as? String {
                showMessageHUD(message)
            } else {
                checkData()
            }
        }
    }
}
