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
    
    func preview(_ controller: PhotoPreviewController, didChangeIndex index: Int)
}

extension PhotoPreviewControllerDelegate {
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int) { }
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int) { }
    func previewController(_ controller: PhotoPreviewController, useOriginalImage: Bool) { }
    func previewControllerDidClickBack(_ controller: PhotoPreviewController) { }
    func previewControllerDidClickDone(_ controller: PhotoPreviewController) { }
    func previewControllerWillDisappear(_ controller: PhotoPreviewController) { }
    func preview(_ controller: PhotoPreviewController, didChangeIndex index: Int) { }
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
    
    private(set) lazy var lgView: PreviewLGView = {
        let view = PreviewLGView(frame: .zero)
        return view
    }()
    private(set) lazy var navigationBar: PickerPreviewNavigationBar = {
        let view = PickerPreviewNavigationBar(frame: .zero)
        view.useOriginalImage = manager.useOriginalImage
        view.backEvent.delegate(on: self) { (self, _) in
            self.backButtonTapped()
        }
        view.selectEvent.delegate(on: self) { (self, _) in
            self.selectButtonTapped()
        }
        view.editEvent.delegate(on: self) { (self, _) in
            self.editButtonTapped()
        }
        view.useOriginalImageEvent.delegate(on: self) { (self, flag) in
            self.updateOriginalImage(flag)
        }
        return view
    }()
    private lazy var thumbnailPreviewView: PickerThumbnailPreviewView = {
        let view = PickerThumbnailPreviewView(frame: .zero)
        view.delegate = self
        view.configure(with: assets, manager: manager, currentIndex: options.index)
        return view
    }()
    private(set) lazy var toolBar: PickerToolBar = {
        let view = PickerToolBar(style: .preview)
        view.originalButton.isSelected = manager.useOriginalImage
        view.leftButton.isHidden = true
        #if ANYIMAGEKIT_ENABLE_EDITOR
        view.leftButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        #endif
        view.originalButton.addTarget(self, action: #selector(originalImageButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var lgToolBar: PreviewLGToolBar = {
        let view = PreviewLGToolBar(frame: .zero)
        #if ANYIMAGEKIT_ENABLE_EDITOR
        view.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        #endif
        view.originalButton.addTarget(self, action: #selector(lgOriginalImageButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(lgDoneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        update(options: manager.options)
        syncPreviewToolBar(for: assets[currentIndex])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBar(hidden: false, animated: true)
        updateSafeAreaLayoutGuide(isAnimated: true)
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
        navigationBar.setNum(asset.selectedNum, isSelected: asset.isSelected, animated: false)
        thumbnailPreviewView.reloadSelectionState()
        syncPreviewToolBar(for: asset)
        thumbnailPreviewView.setCurrentIndex(index, animated: false)
        delegate?.preview(self, didChangeIndex: index)
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
            updateSafeAreaLayoutGuide(isAnimated: true)
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
        view.addSubview(previewToolBarView)
        view.addSubview(thumbnailPreviewView)
        let color = UIColor.create(style: manager.options.theme.style, light: .white, dark: .black)
        transition.presentationController?.maskView.backgroundColor = color
        
        setupLayout()
        setBar(hidden: true, animated: false, isNormal: false)
        updateSafeAreaLayoutGuide()
        
        for subview in (pageManager.container?.view.subviews ?? []) {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
                break
            }
        }
    }
    
    /// 设置视图布局
    private func setupLayout() {
        navigationBar.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }
        thumbnailPreviewView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(previewToolBarView.snp.top)
            make.height.equalTo(45)
        }
        previewToolBarView.isHidden = false
        
        previewToolBarView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            if isLiquidGlassEnabled {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                maker.height.equalTo(56)
            } else {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-56)
                maker.bottom.equalToSuperview()
            }
        }
        updateSafeAreaLayoutGuide()
    }
    
    private func updateSafeAreaLayoutGuide(isAnimated: Bool = false) {
        updateContentSafeAreaLayoutGuide(isAnimated: isAnimated) { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            if self.navigationBar.alpha == 0 {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalTo(self.thumbnailPreviewView.snp.top)
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
            self.previewToolBarView.alpha = hidden ? 0 : 1
            self.thumbnailPreviewView.alpha = hidden ? 0 : 1
        }
    }
    
    private var isLiquidGlassEnabled: Bool {
        if #available(iOS 26.0, *), !manager.options.designRequiresCompatibility {
            return true
        }
        return false
    }
    
    private var previewToolBarView: UIView {
        isLiquidGlassEnabled ? lgToolBar : toolBar
    }
    
    private func syncPreviewToolBar(for asset: Asset) {
        let showOriginal = manager.options.allowUseOriginalImage && asset.phAsset.mediaType == .image
        toolBar.originalButton.isHidden = !showOriginal
        toolBar.originalButton.isSelected = manager.useOriginalImage
        lgToolBar.setShowsOriginal(showOriginal)
        lgToolBar.setOriginalSelected(manager.useOriginalImage)
        
        let doneEnabled = sourceType == .selectedAssets ? !manager.selectedAssets.isEmpty : true
        toolBar.setDoneEnable(doneEnabled)
        lgToolBar.setDoneEnable(doneEnabled)
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        let canEdit = (asset.mediaType == .photo && manager.options.editorOptions.contains(.photo))
            || (asset.phAsset.mediaType == .video && manager.options.editorOptions.contains(.video))
        toolBar.leftButton.isHidden = !canEdit
        lgToolBar.setShowsEdit(canEdit)
        #else
        toolBar.leftButton.isHidden = true
        lgToolBar.setShowsEdit(false)
        #endif
    }
}

// MARK: - Target
extension PhotoPreviewController {
    
    /// NavigationBar - Back
    @objc func backButtonTapped() {
        delegate?.previewControllerWillDisappear(self)
        dismiss(animated: true, completion: nil)
        setStatusBar(hidden: false)
        trackObserver?.track(event: .pickerBackInPreview, userInfo: [:])
    }
    
    /// NavigationBar - Select
    @objc func selectButtonTapped() {
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
        
        navigationBar.setNum(asset.selectedNum, isSelected: asset.isSelected, animated: true)
        thumbnailPreviewView.reloadSelectionState()
        syncPreviewToolBar(for: asset)
        trackObserver?.track(event: .pickerSelect, userInfo: [.isOn: asset.isSelected, .page: AnyImagePage.pickerPreview])
        
        updateSafeAreaLayoutGuide(isAnimated: true)
    }
    
    /// ToolBar - Original
    @objc private func originalImageButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        updateOriginalImage(sender.isSelected)
    }
    
    @objc private func lgOriginalImageButtonTapped(_ sender: UIButton) {
        updateOriginalImage(!manager.useOriginalImage)
    }
    
    private func updateOriginalImage(_ flag: Bool) {
        manager.useOriginalImage = flag
        delegate?.previewController(self, useOriginalImage: flag)
        
        // 选择当前照片
        if manager.useOriginalImage && !manager.isUpToLimit {
            let asset = assets[currentIndex]
            if !asset.isSelected {
                selectButtonTapped()
            }
        }
        syncPreviewToolBar(for: assets[currentIndex])
        trackObserver?.track(event: .pickerOriginalImage, userInfo: [.isOn: flag, .page: AnyImagePage.pickerPreview])
    }
    
    /// ToolBar - Done
    @objc private func doneButtonTapped(_ sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false
        handleDoneAction()
    }
    
    @objc private func lgDoneButtonTapped(_ sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false
        handleDoneAction()
    }
    
    private func handleDoneAction() {
        let asset = assets[currentIndex]
        if manager.selectedAssets.isEmpty {
            if case .disable(let rule) = asset.state {
                let message = rule.alertMessage(for: asset, assetList: manager.selectedAssets)
                showAlert(message: message, stringConfig: manager.options.theme)
                return
            }
            selectButtonTapped()
        }
        transition.presentationController?.updateMask = false
        delegate?.previewControllerWillDisappear(self)
        delegate?.previewControllerDidClickDone(self)
        trackObserver?.track(event: .pickerDone, userInfo: [.page: AnyImagePage.pickerPreview])
    }
}

// MARK: - BrowserPreviewViewDelegate
extension PhotoPreviewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewportWidth = scrollView.bounds.width
        let pageSpan: CGFloat
        if scrollView.contentSize.width > viewportWidth {
            pageSpan = (scrollView.contentSize.width - viewportWidth) / 2
        } else {
            pageSpan = viewportWidth + pageManager.spacing
        }
        guard pageSpan > 0 else { return }
        
        let contentOffsetX = scrollView.contentOffset.x
        let baseOffset = pageSpan
        let offsetFromBase = contentOffsetX - baseOffset
        
        if abs(offsetFromBase) < 1 { return }
        
        let fromIndex = currentIndex
        let toIndex: Int
        let progress: CGFloat
        
        if offsetFromBase > 0 {
            toIndex = min(fromIndex + 1, assets.count - 1)
            guard toIndex > fromIndex else { return }
            progress = offsetFromBase / pageSpan
        } else {
            toIndex = max(fromIndex - 1, 0)
            guard toIndex < fromIndex else { return }
            progress = abs(offsetFromBase) / pageSpan
        }
        
        thumbnailPreviewView.updateScrollProgress(
            fromIndex: fromIndex,
            toIndex: toIndex,
            progress: progress
        )
    }
}

// MARK: - PickerThumbnailPreviewViewDelegate
extension PhotoPreviewController: PickerThumbnailPreviewViewDelegate {
    
    func thumbnailPreviewView(_ view: PickerThumbnailPreviewView, didSelectAt index: Int) {
        currentIndex = index
    }
}
