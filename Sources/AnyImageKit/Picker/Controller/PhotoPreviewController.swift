//
//  PhotoPreviewController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

protocol PhotoPreviewControllerDelegate: AnyObject {
    
    /// 选择一张图片，需要返回所选图片的序号
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int)
    
    /// 取消选择一张图片
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int)
    
    /// 开启/关闭原图
    func previewController(_ controller: PhotoPreviewController, useOriginalImage: Bool)
    
    /// 点击返回
    func previewControllerDidClickBack(_ controller: PhotoPreviewController)
    
    /// 点击完成
    func previewControllerDidClickDone(_ controller: PhotoPreviewController)
    
    /// 即将消失
    func previewControllerWillDisappear(_ controller: PhotoPreviewController)
}

extension PhotoPreviewControllerDelegate {
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int) { }
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int) { }
    func previewController(_ controller: PhotoPreviewController, useOriginalImage: Bool) { }
    func previewControllerDidClickBack(_ controller: PhotoPreviewController) { }
    func previewControllerDidClickDone(_ controller: PhotoPreviewController) { }
}

final class PhotoPreviewController: BrowserController, PickerOptionsConfigurable {
    
    enum SourceType: Int {
        case album
        case selectedAssets
    }
    
    weak var delegate: PhotoPreviewControllerDelegate?
    
    let manager: PickerManager
    let sourceType: SourceType
    let assets: [Asset]
    
    private var toolBarHiddenStateBeforePan = false
    
    init(manager: PickerManager, sourceType: SourceType, assets: [Asset], options: BrowserOptionsInfo, browserDelegate: BrowserControllerDelegate) {
        self.manager = manager
        self.sourceType = sourceType
        self.assets = assets
        super.init(options: options, delegate: browserDelegate)
    }
    
    @MainActor public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var navigationBar: PickerPreviewNavigationBar = {
        let view = PickerPreviewNavigationBar(frame: .zero)
        view.backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        view.selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var toolBar: PickerToolBar = {
        let view = PickerToolBar(style: .preview)
        view.originalButton.isSelected = manager.useOriginalImage
        view.leftButton.isHidden = true
        #if ANYIMAGEKIT_ENABLE_EDITOR
        view.leftButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        #endif
        view.originalButton.addTarget(self, action: #selector(originalImageButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var indexView: PickerPreviewIndexView = {
        let view = PickerPreviewIndexView(manager: manager, sourceType: sourceType)
        view.isHidden = true
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        update(options: manager.options)
        
//        if #available(iOS 18.0, *) {
//            preferredTransition = .zoom(sourceViewProvider: { [weak self] context in
//                guard let self = self else { return nil }
//                return self.options.relatedView?(self.currentIndex)
//            })
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBar(hidden: false, animated: true)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch ScreenHelper.interfaceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .unknown:
            return .portrait
        @unknown default:
            return .portrait
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return ScreenHelper.interfaceOrientation
    }
    
    override func setStatusBar(hidden: Bool) {
        if let controller = (presentingViewController as? AnyImageNavigationController)?.topViewController as? AssetPickerViewController {
            controller.setStatusBar(hidden: hidden)
        }
    }
    
    // MARK: - override
    
    override func browser(_ browser: BrowserController, didChangeIndex index: Int) {
        super.browser(browser, didChangeIndex: index)
        let asset = assets[index]
        navigationBar.selectButton.isEnabled = true
        navigationBar.selectButton.setNum(asset.selectedNum, isSelected: asset.isSelected, animated: false)
        indexView.currentAsset = asset

        if manager.options.allowUseOriginalImage {
            toolBar.originalButton.isHidden = asset.phAsset.mediaType != .image
        }
        #if ANYIMAGEKIT_ENABLE_EDITOR
        autoSetEditorButtonHidden()
        #endif
    }
    
    override func browserDidBeginPan(_ browser: BrowserController) {
        super.browserDidBeginPan(browser)
        toolBarHiddenStateBeforePan = navigationBar.alpha == 0
    }
    
    override func browser(_ browser: BrowserController, didPanScale scale: CGFloat) {
        super.browser(browser, didPanScale: scale)
        setBar(hidden: true, isNormal: false)
    }
    
    override func browser(_ browser: BrowserController, didEndPanWithExit isExit: Bool) {
        super.browser(browser, didEndPanWithExit: isExit)
        if isExit {
            delegate?.previewControllerWillDisappear(self)
            setStatusBar(hidden: false)
        } else if !toolBarHiddenStateBeforePan {
            setBar(hidden: false, isNormal: false)
        }
    }
    
    override func browserDidSingleTap(_ browser: BrowserController) {
        setBar(hidden: navigationBar.alpha == 1, animated: false)
        super.browserDidSingleTap(browser)
        updateSafeAreaLayoutGuide(isAnimated: true)
    }
    
    override func shouldHideToolBar(in browser: BrowserController) -> Bool {
        return navigationBar.alpha == 0
    }
}

// MARK: - Public function
extension PhotoPreviewController {
    
    func reloadWhenPhotoLibraryDidChange() {
        dismiss(animated: true)
    }
}

// MARK: - Private function
extension PhotoPreviewController {
    
    /// 添加视图
    private func setupViews() {
        closeButton.isHidden = true
        pageLabel.isHidden = true
        view.addSubview(navigationBar)
        view.addSubview(toolBar)
        view.addSubview(indexView)
        let color = UIColor.create(style: manager.options.theme.style, light: .white, dark: .black)
        transition.presentationController?.maskView.backgroundColor = color
        
        setupLayout()
        setBar(hidden: true, animated: false, isNormal: false)
    }
    
    /// 设置视图布局
    private func setupLayout() {
        navigationBar.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }
        toolBar.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-56)
        }
        indexView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(toolBar.snp.top)
            maker.height.equalTo(96)
        }
        updateSafeAreaLayoutGuide()
    }
    
    private func updateSafeAreaLayoutGuide(isAnimated: Bool = false) {
        updateContentSafeAreaLayoutGuide(isAnimated: isAnimated) { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            if indexView.isHidden || navigationBar.alpha == 0 {
                make.bottom.equalTo(toolBar.snp.top)
            } else {
                make.bottom.equalTo(indexView.snp.top)
            }
        }
    }
    
    /// 显示/隐藏工具栏
    private func setBar(hidden: Bool, animated: Bool = true, isNormal: Bool = true) {
        if navigationBar.alpha == 0 && hidden { return }
        if navigationBar.alpha == 1 && !hidden { return }
        if isNormal {
            setStatusBar(hidden: hidden)
            let color = UIColor.create(style: manager.options.theme.style, light: .white, dark: .black)
            transition.presentationController?.maskView.backgroundColor = hidden ? UIColor.black : color
        }

        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.navigationBar.alpha = hidden ? 0 : 1
            self.toolBar.alpha = hidden ? 0 : 1
            self.indexView.alpha = hidden ? 0 : 1
        }
    }
}

// MARK: - Target
extension PhotoPreviewController {
    
    /// NavigationBar - Back
    @objc private func backButtonTapped(_ sender: UIButton) {
        delegate?.previewControllerWillDisappear(self)
        dismiss(animated: true, completion: nil)
        setStatusBar(hidden: false)
        trackObserver?.track(event: .pickerBackInPreview, userInfo: [:])
    }
    
    /// NavigationBar - Select
    @objc func selectButtonTapped(_ sender: NumberCircleButton) {
        let asset = assets[currentIndex]
        
        if !asset.isSelected {
            let result = manager.addSelectedAsset(asset)
            if result.success {
                delegate?.previewController(self, didSelected: currentIndex)
            } else if !result.message.isEmpty {
                showAlert(message: result.message, stringConfig: manager.options.theme)
            }
        } else {
            manager.removeSelectedAsset(asset)
            delegate?.previewController(self, didDeselected: currentIndex)
        }
        
        navigationBar.selectButton.setNum(asset.selectedNum, isSelected: asset.isSelected, animated: true)
        indexView.didChangeSelectedAsset()
        trackObserver?.track(event: .pickerSelect, userInfo: [.isOn: asset.isSelected, .page: AnyImagePage.pickerPreview])
        
        if sourceType == .selectedAssets {
            toolBar.setDoneEnable(!manager.selectedAssets.isEmpty)
        }
        updateSafeAreaLayoutGuide(isAnimated: true)
    }
    
    /// ToolBar - Original
    @objc private func originalImageButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        manager.useOriginalImage = sender.isSelected
        delegate?.previewController(self, useOriginalImage: sender.isSelected)
        
        // 选择当前照片
        if manager.useOriginalImage && !manager.isUpToLimit {
            let asset = assets[currentIndex]
            if !asset.isSelected {
                selectButtonTapped(navigationBar.selectButton)
            }
        }
        trackObserver?.track(event: .pickerOriginalImage, userInfo: [.isOn: sender.isSelected, .page: AnyImagePage.pickerPreview])
    }
    
    /// ToolBar - Done
    @objc private func doneButtonTapped(_ sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false
        let asset = assets[currentIndex]
        if manager.selectedAssets.isEmpty {
            if case .disable(let rule) = asset.state {
                let message = rule.alertMessage(for: asset, assetList: manager.selectedAssets)
                showAlert(message: message, stringConfig: manager.options.theme)
                return
            }
            selectButtonTapped(navigationBar.selectButton)
        }
        transition.presentationController?.updateMask = false
        delegate?.previewControllerWillDisappear(self)
        delegate?.previewControllerDidClickDone(self)
        trackObserver?.track(event: .pickerDone, userInfo: [.page: AnyImagePage.pickerPreview])
    }
}

// MARK: - PickerPreviewIndexViewDelegate
extension PhotoPreviewController: PickerPreviewIndexViewDelegate {

    func pickerPreviewIndexView(_ view: PickerPreviewIndexView, didSelect asset: Asset) {
        switch sourceType {
        case .album:
            currentIndex = asset.idx
        case .selectedAssets:
            guard let index = assets.firstIndex(of: asset) else { return }
            currentIndex = index
        }

        #if ANYIMAGEKIT_ENABLE_EDITOR
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.autoSetEditorButtonHidden()
        }
        #endif
    }
}
