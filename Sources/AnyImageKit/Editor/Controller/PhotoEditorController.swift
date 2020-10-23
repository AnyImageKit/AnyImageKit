//
//  PhotoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol PhotoEditorControllerDelegate: AnyObject {
    
    func photoEditorDidCancel(_ editor: PhotoEditorController)
    func photoEditor(_ editor: PhotoEditorController, didFinishEditing photo: UIImage, isEdited: Bool)
}

final class PhotoEditorController: AnyImageViewController {
    
    private lazy var contentView: PhotoEditorContentView = {
        let view = PhotoEditorContentView(frame: self.view.bounds, image: image, options: options, cache: cache)
        view.delegate = self
        view.canvas.brush.color = options.penColors[options.defaultPenIndex].color
        return view
    }()
    private lazy var toolView: EditorToolView = {
        let view = EditorToolView(frame: self.view.bounds, options: options)
        view.delegate = self
        view.penToolView.undoButton.isEnabled = contentView.canvasCanUndo()
        view.mosaicToolView.undoButton.isEnabled = contentView.mosaicCanUndo()
        view.cropToolView.currentOptionIdx = cache?.cropOptionIdx ?? 0
        return view
    }()
    private lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.setImage(BundleHelper.image(named: "ReturnBackButton"), for: .normal)
        view.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = BundleHelper.editorLocalizedString(key: "Back")
        return view
    }()
    
    private var image: UIImage = UIImage()
    private let resource: EditorPhotoResource
    private let options: EditorPhotoOptionsInfo
    private weak var delegate: PhotoEditorControllerDelegate?
    
    private lazy var context = CIContext()
    private lazy var cache = ImageEditorCache(id: options.cacheIdentifier)
    
    init(photo resource: EditorPhotoResource, options: EditorPhotoOptionsInfo, delegate: PhotoEditorControllerDelegate) {
        self.resource = resource
        self.options = options
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        toolView.selectFirstItemIfNeeded()
    }
    
    private func setupView() {
        view.addSubview(contentView)
        view.addSubview(toolView)
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { maker in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            } else {
                maker.top.equalToSuperview().offset(30)
            }
            maker.left.equalToSuperview().offset(10)
            maker.width.height.equalTo(50)
        }
    }
    
    private func loadData() {
        resource.loadImage { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                hideHUD()
                self.image = image
                self.setupView()
            case .failure(let error):
                if error == .cannotFindInLocal {
                    showWaitHUD()
                    return
                }
                _print("Fetch image failed: \(error.localizedDescription)")
                self.delegate?.photoEditorDidCancel(self)
            }
        }
    }
}

// MARK: - Target
extension PhotoEditorController {
    
    /// 返回按钮触发
    @objc private func backButtonTapped(_ sender: UIButton) {
        delegate?.photoEditorDidCancel(self)
    }
}

// MARK: - PhotoEditorContentViewDelegate
extension PhotoEditorController: PhotoEditorContentViewDelegate {
    
    func contentViewTapped() {
        if toolView.currentOption != .crop {
            let hidden = toolView.alpha == 1
            UIView.animate(withDuration: 0.25) {
                self.toolView.alpha = hidden ? 0 : 1
                self.backButton.alpha = hidden ? 0 : 1
            }
        }
    }
    
    /// 开始涂鸦
    func photoDidBeginPen() {
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 0
            self.backButton.alpha = 0
        }
    }
    
    /// 结束涂鸦
    func photoDidEndPen() {
        if let option = toolView.currentOption {
            switch option {
            case .pen:
                toolView.penToolView.undoButton.isEnabled = true
            case .mosaic:
                toolView.mosaicToolView.undoButton.isEnabled = true
            default:
                break
            }
        }
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 1
            self.backButton.alpha = 1
        }
    }
    
    /// 马赛克图层创建完成
    func mosaicDidCreated() {
        hideHUD()
        guard let option = toolView.currentOption else { return }
        if option == .mosaic {
            contentView.mosaic?.isUserInteractionEnabled = true
        }
    }
    
    /// 开始编辑文本
    func inputTextWillBeginEdit(_ data: TextData) {
        openInputController(data)
    }
}

// MARK: - EditorToolViewDelegate
extension PhotoEditorController: EditorToolViewDelegate {
    
    /// 点击了功能按钮
    func toolView(_ toolView: EditorToolView, optionDidChange option: EditorPhotoToolOption?) {
        contentView.canvas.isUserInteractionEnabled = false
        contentView.mosaic?.isUserInteractionEnabled = false
        contentView.scrollView.isScrollEnabled = option == nil
        guard let option = option else { return }
        switch option {
        case .pen:
            contentView.canvas.isUserInteractionEnabled = true
            trackObserver?.track(event: .photoPen, userInfo: [:])
        case .text:
            openInputController()
            trackObserver?.track(event: .photoText, userInfo: [:])
        case .crop:
            willBeginCrop()
            if let option = options.cropOptions.first, !contentView.didCrop {
                toolView.cropToolView.currentOption = option
                contentView.cropStart(with: option)
            } else {
                contentView.cropStart()
            }
            trackObserver?.track(event: .photoCrop, userInfo: [:])
        case .mosaic:
            if contentView.mosaic == nil {
                showWaitHUD()
            }
            contentView.mosaic?.isUserInteractionEnabled = true
            trackObserver?.track(event: .photoMosaic, userInfo: [:])
        }
    }
    
    /// 画笔切换颜色
    func toolView(_ toolView: EditorToolView, colorDidChange color: UIColor) {
        contentView.canvas.brush.color = color
    }
    
    /// 马赛克切换类型
    func toolView(_ toolView: EditorToolView, mosaicDidChange idx: Int) {
        contentView.setMosaicImage(idx)
    }
    
    /// 撤销 - 仅用于画笔和马赛克
    func toolViewUndoButtonTapped(_ toolView: EditorToolView) {
        guard let option = toolView.currentOption else { return }
        switch option {
        case .pen:
            contentView.canvasUndo()
            toolView.penToolView.undoButton.isEnabled = contentView.canvasCanUndo()
        case .mosaic:
            contentView.mosaicUndo()
            toolView.mosaicToolView.undoButton.isEnabled = contentView.mosaicCanUndo()
        default:
            break
        }
    }
    
    /// 设置裁剪尺寸
    func toolViewCrop(_ toolView: EditorToolView, didClickCropOption option: EditorCropOption) {
        contentView.setCrop(option)
    }
    
    /// 取消裁剪
    func toolViewCropCancelButtonTapped(_ toolView: EditorToolView) {
        if options.toolOptions.count == 1 {
            backButtonTapped(backButton)
            return
        }
        
        backButton.isHidden = false
        contentView.cropCancel { [weak self] (_) in
            self?.didEndCroping()
        }
    }
    
    /// 完成裁剪
    func toolViewCropDoneButtonTapped(_ toolView: EditorToolView) {
        backButton.isHidden = false
        contentView.cropDone { [weak self] (_) in
            self?.didEndCroping()
            if self?.options.toolOptions.count == 1 {
                self?.toolViewDoneButtonTapped(toolView)
            }
        }
    }
    
    /// 还原裁剪
    func toolViewCropResetButtonTapped(_ toolView: EditorToolView) {
        contentView.cropReset()
    }
    
    /// 最终完成按钮
    func toolViewDoneButtonTapped(_ toolView: EditorToolView) {
        contentView.deactivateAllTextView()
        guard let image = getResultImage() else { return }
        saveEditPath()
        delegate?.photoEditor(self, didFinishEditing: image, isEdited: contentView.isEdited)
    }
}

// MARK: - InputTextViewControllerDelegate
extension PhotoEditorController: InputTextViewControllerDelegate {
    
    /// 取消输入
    func inputTextDidCancel(_ controller: InputTextViewController) {
        didEndInputing()
        contentView.restoreHiddenTextView()
    }
    
    /// 完成输入
    func inputText(_ controller: InputTextViewController, didFinishInput data: TextData) {
        didEndInputing()
        contentView.removeHiddenTextView()
        contentView.addText(data: data)
    }
}

// MARK: - Private
extension PhotoEditorController {
    
    /// 获取最终的图片
    private func getResultImage() -> UIImage? {
        guard let source = contentView.imageView.screenshot(image.size).cgImage else { return nil }
        let size = image.size
        let cropRect = contentView.cropRealRect
        
        // 获取原始imageFrame
        let tmpScale = contentView.scrollView.zoomScale
        let tmpOffset = contentView.scrollView.contentOffset
        let tmpContentSize = contentView.scrollView.contentSize
        contentView.scrollView.zoomScale = 1.0
        let imageFrame = contentView.imageView.frame
        contentView.scrollView.zoomScale = tmpScale
        contentView.scrollView.contentOffset = tmpOffset
        contentView.scrollView.contentSize = tmpContentSize
        
        var rect: CGRect = .zero
        rect.origin.x = (cropRect.origin.x - imageFrame.origin.x) / imageFrame.width * size.width
        rect.origin.y = (cropRect.origin.y - imageFrame.origin.y) / imageFrame.height * size.height
        rect.size.width = size.width * cropRect.width / imageFrame.width
        rect.size.height = size.height * cropRect.height / imageFrame.height
        
        guard let cgImage = source.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    /// 存储编辑记录
    private func saveEditPath() {
        if options.cacheIdentifier.isEmpty { return }
        contentView.setupLastCropDataIfNeeded()
        let textDataList = contentView.textImageViews.map{ $0.data }
        let cache = ImageEditorCache(id: options.cacheIdentifier,
                                     cropData: contentView.lastCropData,
                                     cropOptionIdx: toolView.cropToolView.currentOptionIdx,
                                     textDataList: textDataList,
                                     penCacheList: contentView.penCache.diskCacheList,
                                     mosaicCacheList: contentView.mosaicCache.diskCacheList)
        cache.save()
    }
}

// MARK: - Crop
extension PhotoEditorController {
    
    /// 准备开始裁剪
    private func willBeginCrop() {
        backButton.isHidden = true
        contentView.scrollView.isScrollEnabled = true
        contentView.deactivateAllTextView()
        let image = contentView.imageView.screenshot(self.image.size)
        contentView.canvas.isHidden = true
        contentView.hiddenAllTextView()
        contentView.imageBeforeCrop = contentView.imageView.image
        contentView.imageView.image = image
    }
    
    /// 已经结束裁剪
    private func didEndCroping() {
        contentView.canvas.isHidden = false
        contentView.restoreHiddenTextView()
        contentView.imageView.image = contentView.imageBeforeCrop
    }
}

// MARK: - InputText
extension PhotoEditorController {
    
    /// 打开文本编辑器
    private func openInputController(_ data: TextData = TextData()) {
        willBeginInput()
        let coverImage = getInputCoverImage()
        let controller = InputTextViewController(options: options, data: data, coverImage: coverImage, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    /// 获取输入界面的占位图
    private func getInputCoverImage() -> UIImage? {
        return contentView.screenshot().gaussianImage(context: context, blur: 8)
    }
    
    /// 准备开始输入文本
    private func willBeginInput() {
        backButton.isHidden = true
        toolView.topCoverView.isHidden = true
        toolView.bottomCoverView.isHidden = true
        toolView.doneButton.isHidden = true
        toolView.editOptionsView.isHidden = true
        toolView.editOptionsView.unselectButtons()
        contentView.deactivateAllTextView()
    }
    
    /// 已经结束输入文本
    private func didEndInputing() {
        backButton.isHidden = false
        toolView.topCoverView.isHidden = false
        toolView.bottomCoverView.isHidden = false
        toolView.doneButton.isHidden = false
        toolView.editOptionsView.isHidden = false
        contentView.scrollView.isScrollEnabled = true
    }
}
