//
//  _PhotoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol PhotoEditorControllerDelegate: class {
    
    func photoEditorDidFinishEdit(_ controller: PhotoEditorController, photo: UIImage)
}

final class PhotoEditorController: UIViewController {
    
    weak var delegate: PhotoEditorControllerDelegate?
    
    private lazy var contentView: PhotoContentView = {
        let view = PhotoContentView(frame: self.view.bounds, image: manager.image, config: manager.photoConfig)
        view.delegate = self
        view.canvas.brush.color = manager.photoConfig.penColors[manager.photoConfig.defaultPenIdx]
        return view
    }()
    private lazy var toolView: EditorToolView = {
        let view = EditorToolView(frame: self.view.bounds, config: EditorManager.shared.photoConfig)
        view.delegate = self
        return view
    }()
    private lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "ReturnBackButton"), for: .normal)
        view.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var singleTap: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
    }()
    
    private let manager = EditorManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupView() {
        view.addSubview(contentView)
        view.addSubview(toolView)
        view.addSubview(backButton)
        view.addGestureRecognizer(singleTap)
        
        backButton.snp.makeConstraints { (maker) in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            } else {
                maker.top.equalToSuperview().offset(40)
            }
            maker.left.equalToSuperview().offset(20)
            maker.width.height.equalTo(30)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Target
extension PhotoEditorController {
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSingleTap(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: toolView)
        let tapped = toolView.responseTouch(point)
        if !tapped && toolView.currentOption != .crop { // 未命中视图时，显示/隐藏所有视图
            let hidden = toolView.alpha == 1
            UIView.animate(withDuration: 0.25) {
                self.toolView.alpha = hidden ? 0 : 1
                self.backButton.alpha = hidden ? 0 : 1
            }
        }
    }
}

// MARK: - PhotoContentViewDelegate
extension PhotoEditorController: PhotoContentViewDelegate {
    
    func photoDidBeginPen() {
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 0
            self.backButton.alpha = 0
        }
    }
    
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
    
    func mosaicDidCreated() {
        hideHUD()
        guard let option = toolView.currentOption else { return }
        if option == .mosaic {
            contentView.mosaic?.isUserInteractionEnabled = true
        }
    }
}

// MARK: - EditorToolViewDelegate
extension PhotoEditorController: EditorToolViewDelegate {
    
    func toolView(_ toolView: EditorToolView, optionDidChange option: ImageEditorController.PhotoEditOption?) {
        contentView.canvas.isUserInteractionEnabled = false
        contentView.mosaic?.isUserInteractionEnabled = false
        contentView.scrollView.isScrollEnabled = option == nil
        guard let option = option else { return }
        switch option {
        case .pen:
            contentView.canvas.isUserInteractionEnabled = true
        case .text:
            break
        case .crop:
            backButton.isHidden = true
            contentView.scrollView.isScrollEnabled = true
            contentView.cropStart()
        case .mosaic:
            if contentView.mosaic == nil {
                showWaitHUD()
            }
            contentView.mosaic?.isUserInteractionEnabled = true
        }
    }
    
    func toolView(_ toolView: EditorToolView, colorDidChange idx: Int) {
        contentView.canvas.brush.color = EditorManager.shared.photoConfig.penColors[idx]
    }
    
    func toolView(_ toolView: EditorToolView, mosaicDidChange idx: Int) {
        contentView.setMosaicImage(idx)
    }
    
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
    
    func toolViewCropCancelButtonTapped(_ toolView: EditorToolView) {
        backButton.isHidden = false
        contentView.cropCancel()
    }
    
    func toolViewCropDoneButtonTapped(_ toolView: EditorToolView) {
        backButton.isHidden = false
        contentView.cropDone()
    }
    
    func toolViewCropResetButtonTapped(_ toolView: EditorToolView) {
        contentView.cropReset()
    }
    
    func toolViewDoneButtonTapped(_ toolView: EditorToolView) {
        guard let source = contentView.imageView.screenshot.cgImage else { return }
        let size = CGSize(width: source.width, height: source.height)
        let cropRect = contentView.cropRealRect
        let imageRect = contentView.imageView.frame
        var rect: CGRect = .zero
        rect.origin.x = (cropRect.origin.x - imageRect.origin.x) / imageRect.width * size.width
        rect.origin.y = (cropRect.origin.y - imageRect.origin.y) / imageRect.height * size.height
        rect.size.width = size.width * cropRect.width / imageRect.width
        rect.size.height = size.height * cropRect.height / imageRect.height
        
        guard let cgImage = source.cropping(to: rect) else { return }
        let image = UIImage(cgImage: cgImage)
        saveEditPath()
        delegate?.photoEditorDidFinishEdit(self, photo: image)
        dismiss(animated: false, completion: nil)
    }
}

extension PhotoEditorController {
    
    private func saveEditPath() {
        let config = manager.photoConfig
        if config.cacheIdentifier.isEmpty { return }
        let cache = EditorImageCache(id: config.cacheIdentifier, cropData: contentView.lastCropData, penCacheList: contentView.penCache.cacheList, mosaicCacheList: contentView.mosaicCache.cacheList)
        cache.save()
    }
}
