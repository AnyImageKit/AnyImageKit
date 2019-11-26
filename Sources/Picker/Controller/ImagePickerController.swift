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
        picker.dismiss(animated: true, completion: nil)
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
    
    public var captureConfig: CaptureConfig {
        return manager.captureConfig
    }
    
    private var containerSize: CGSize = .zero
    private var hasOverrideGeneratingDeviceOrientation: Bool = false
    private var hiddenStatusBar: Bool = false
    private var didFinishSelect: Bool = false
    private let lock: NSLock = .init()
    
    private let manager: PickerManager = .init()
    
    public required init(config: Config = .init(), delegate: ImagePickerControllerDelegate) {
        enableDebugLog = config.enableDebugLog
        // Note:
        // Can't use `init(rootViewController:)` cause it will also call `init(nibName:,bundle:)` and reset `manager` even it's declaration by `let`
        super.init(nibName: nil, bundle: nil)
        self.manager.config = config
        self.pickerDelegate = delegate
        
        let rootViewController = AssetPickerViewController(manager: manager)
        rootViewController.delegate = self
        self.viewControllers = [rootViewController]
        
        navigationBar.barTintColor = config.theme.backgroundColor
        navigationBar.tintColor = config.theme.textColor
        addNotifications()
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        EditorImageCache.clearDiskCache()
        #endif
    }
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    convenience public init(config: Config = .init(), editorConfig: EditorConfig = .init(), delegate: ImagePickerControllerDelegate) {
        self.init(config: config, delegate: delegate)
        self.manager.editorConfig = editorConfig
    }
    #endif
    
    convenience public init(config: Config = .init(), captureConfig: CaptureConfig = .init(), delegate: ImagePickerControllerDelegate) {
        self.init(config: config, delegate: delegate)
        self.manager.captureConfig = captureConfig
    }
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    convenience public init(config: Config = .init(), editorConfig: EditorConfig = .init(), captureConfig: CaptureConfig = .init(), delegate: ImagePickerControllerDelegate) {
        self.init(config: config, delegate: delegate)
        self.manager.editorConfig = editorConfig
        self.manager.captureConfig = captureConfig
    }
    #endif
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotifications()
        #if ANYIMAGEKIT_ENABLE_EDITOR
        EditorImageCache.clearDiskCache()
        #endif
        manager.clearAll()
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
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if let _ = presentedViewController as? PhotoPreviewController {
            presentingViewController?.dismiss(animated: flag, completion: completion)
        } else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
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
            assets.forEach {
                if let image = $0._image, image.size != .zero  {
                    let resizedImage = UIImage.resize(from: image, limitSize: limitSize, isExact: true)
                    $0._images[.output] = resizedImage
                    $0._images[.edited] = nil
                    $0._images[.initial] = nil
                }
            }
        } else {
            assets.forEach {
                $0._images[.output] = $0._image
                $0._images[.edited] = nil
                $0._images[.initial] = nil
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
