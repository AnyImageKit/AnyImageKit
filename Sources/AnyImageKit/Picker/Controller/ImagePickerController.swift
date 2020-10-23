//
//  ImagePickerController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImagePickerControllerDelegate: AnyObject {
    
    func imagePickerDidCancel(_ picker: ImagePickerController)
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult)
}

extension ImagePickerControllerDelegate {
    
    public func imagePickerDidCancel(_ picker: ImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

open class ImagePickerController: AnyImageNavigationController {
    
    open weak var pickerDelegate: ImagePickerControllerDelegate?
    
    private var containerSize: CGSize = .zero
    private var hiddenStatusBar: Bool = false
    private var didFinishSelect: Bool = false
    private let workQueue = DispatchQueue.init(label: "org.AnyImageProject.AnyImageKit.DispatchQueue.ImagePickerController")
    
    private let manager: PickerManager = .init()
    
    public required init(options: PickerOptionsInfo) {
        enableDebugLog = options.enableDebugLog
        // Note:
        // Can't use `init(rootViewController:)` cause it will also call `init(nibName:,bundle:)` and reset `manager` even it's declaration by `let`
        super.init(nibName: nil, bundle: nil)
        let newOptions = check(options: options)
        self.addNotifications()
        self.manager.options = newOptions
        
        let rootViewController = AssetPickerViewController(manager: manager)
        rootViewController.delegate = self
        self.viewControllers = [rootViewController]
        
        navigationBar.barTintColor = newOptions.theme.backgroundColor
        navigationBar.tintColor = newOptions.theme.textColor
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        ImageEditorCache.clearDiskCache()
        #endif
    }
    
    public convenience init(options: PickerOptionsInfo, delegate: ImagePickerControllerDelegate) {
        self.init(options: options)
        self.pickerDelegate = delegate
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotifications()
        #if ANYIMAGEKIT_ENABLE_EDITOR
        ImageEditorCache.clearDiskCache()
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
        switch manager.options.theme.style {
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
}

// MARK: - Private function
extension ImagePickerController {
    
    private func check(options: PickerOptionsInfo) -> PickerOptionsInfo {
        var options = options
        options.largePhotoMaxWidth = max(options.photoMaxWidth, options.largePhotoMaxWidth)
        
        #if ANYIMAGEKIT_ENABLE_EDITOR && ANYIMAGEKIT_ENABLE_CAPTURE
        if options.useSameEditorOptionsInCapture {
            options.captureOptions.editorPhotoOptions = options.editorPhotoOptions
            options.captureOptions.editorVideoOptions = options.editorVideoOptions
        }
        #endif
        
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        if !options.selectOptions.contains(.photo) && options.captureOptions.mediaOptions.contains(.photo) {
            options.captureOptions.mediaOptions.remove(.photo)
        }
        if !options.selectOptions.contains(.video) && options.captureOptions.mediaOptions.contains(.video) {
            options.captureOptions.mediaOptions.remove(.video)
        }
        #endif
        
        #if DEBUG
        assert(options.selectLimit >= 1, "Select limit should more then 1")
        #else
        if options.selectLimit < 1 {
            options.selectLimit = 1
        }
        #endif
        
        if options.columnNumber < 3 {
            options.columnNumber = 3
        } else if options.columnNumber > 5 {
            options.columnNumber = 5
        }
        
        if options.selectLimit < options.preselectAssets.count {
            options.preselectAssets.removeLast(options.preselectAssets.count-options.selectLimit)
        }
        
        return options
    }
    
    private func checkData() {
        showWaitHUD()
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let assets = self.manager.selectedAssets
            let isReady = assets.filter{ !$0.isReady }.isEmpty
            if !isReady && !assets.isEmpty { return }
            self.saveEditPhotos(assets) { newAssets in
                self.resizeImagesIfNeeded(newAssets)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    hideHUD()
                    let result = PickerResult(assets: newAssets, useOriginalImage: self.manager.useOriginalImage)
                    self.pickerDelegate?.imagePicker(self, didFinishPicking: result)
                }
            }
        }
    }
    
    private func saveEditPhotos(_ assets: [Asset], completion: @escaping (([Asset]) -> Void)) {
        var assets = assets
        let selectOptions = manager.options.selectOptions
        let group = DispatchGroup()
        for (idx, asset) in assets.enumerated() {
            guard let editedImage = asset._images[.edited] else { continue }
            group.enter()
            manager.savePhoto(image: editedImage) { result in
                switch result {
                case .success(let newAsset):
                    assets[idx] = Asset(idx: asset.idx, asset: newAsset, selectOptions: selectOptions)
                    assets[idx]._images[.initial] = editedImage
                case .failure(let error):
                    _print(error)
                }
                group.leave()
            }
        }
        group.notify(queue: workQueue) {
            completion(assets)
        }
    }
    
    private func resizeImagesIfNeeded(_ assets: [Asset]) {
        if !manager.useOriginalImage {
            let limitSize = CGSize(width: manager.options.photoMaxWidth,
                                   height: manager.options.photoMaxWidth)
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
        manager.resynchronizeAsset()
        checkData()
    }
}

// MARK: - Notifications
extension ImagePickerController {
    
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
                didFinishSelect = false
                showMessageHUD(message)
            } else {
                checkData()
            }
        }
    }
}
