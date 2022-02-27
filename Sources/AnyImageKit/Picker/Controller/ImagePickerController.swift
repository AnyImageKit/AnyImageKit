//
//  ImagePickerController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine
import SnapKit

protocol OptionsInfoUpdatableContent {
    
    associatedtype OptionsInfo
    
    var options: OptionsInfo { get set }
    func update(options: OptionsInfo)
}

open class ImagePickerController: AnyImageNavigationController {
    
    enum Mode {
        case pending
        case photoAsset(PhotoAssetCollectionViewController)
    }
    
    private var containerSize: CGSize = .zero
    private var mode: Mode = .pending
    private var continuation: CheckedContinuation<UserAction<PickerResult>, Never>?
    
    @Published public var options: PickerOptionsInfo = .init()
    
    /// Init Picker
    public convenience init(options: PickerOptionsInfo) {
        self.init()
        self.options = check(options: options)
    }
    
    deinit {
        endGeneratingDeviceOrientationNotifications()
        #if ANYIMAGEKIT_ENABLE_EDITOR
        ImageEditorCache.clearDiskCache()
        #endif
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        beginGeneratingDeviceOrientationNotifications()
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        ImageEditorCache.clearDiskCache()
        #endif
        
        Task {
            await setupPhotoAssetPicker()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newSize = view.frame.size
        if containerSize != .zero, containerSize != newSize {
            _print("ImagePickerController container size did change, new size = \(newSize)")
            NotificationCenter.default.post(name: .containerSizeDidChange, object: nil, userInfo: [containerSizeKey: newSize])
        }
        containerSize = newSize
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if let _ = presentedViewController as? PhotoPreviewController {
            presentingViewController?.dismiss(animated: flag, completion: completion)
        } else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}

extension ImagePickerController {
    
    @MainActor
    private func setupPhotoAssetPicker() async {
        let photoAssetCollectionViewController = PhotoAssetCollectionViewController()
        photoAssetCollectionViewController.trackObserver = self
        viewControllers = [photoAssetCollectionViewController]
        mode = .photoAsset(photoAssetCollectionViewController)
        
        $options
            .assign(to: \.options, on: photoAssetCollectionViewController)
            .store(in: &cancellables)
        
        $options
            .sink { [weak self] newOptions in
                self?.update(options: newOptions)
            }
            .store(in: &cancellables)
        
        let userAction = await photoAssetCollectionViewController.pick()
        switch userAction {
        case .cancel:
            resume(result: .cancel)
        case .interaction(let photoLibrary):
            let result = PickerResult(assets: photoLibrary.selectedItems, useOriginalImage: options.useOriginalImage)
            resume(result: .interaction(result))
        }
    }
}

extension ImagePickerController {
    
    public func pick() async -> UserAction<PickerResult> {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    private func resume(result: UserAction<PickerResult>) {
        if let continuation = continuation {
            continuation.resume(returning: result)
            self.continuation = nil
        }
    }
}

extension ImagePickerController: OptionsInfoUpdatableContent {
    
    func update(options: PickerOptionsInfo) {
        navigationBar.barTintColor = options.theme[color: .background]
        navigationBar.tintColor = options.theme[color: .text]
    }
}

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
}
