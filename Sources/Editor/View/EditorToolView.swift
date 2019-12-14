//
//  EditorToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorToolViewDelegate: class {
    
    func toolView(_ toolView: EditorToolView, optionDidChange option: ImageEditorController.PhotoEditOption?)
    
    func toolView(_ toolView: EditorToolView, colorDidChange idx: Int)
    func toolView(_ toolView: EditorToolView, mosaicDidChange idx: Int)
    
    func toolViewUndoButtonTapped(_ toolView: EditorToolView)
    
    func toolViewCropCancelButtonTapped(_ toolView: EditorToolView)
    func toolViewCropDoneButtonTapped(_ toolView: EditorToolView)
    func toolViewCropResetButtonTapped(_ toolView: EditorToolView)
    
    func toolViewDoneButtonTapped(_ toolView: EditorToolView)
}

final class EditorToolView: UIView {
    
    weak var delegate: EditorToolViewDelegate?
    
    var currentOption: ImageEditorController.PhotoEditOption? {
        editOptionsView.currentOption
    }
    
    private(set) lazy var topCoverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let statusBarHeight = StatusBarHelper.height
        layer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight + 120)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.06).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 0.7, 0.85, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()
    private(set) lazy var bottomCoverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let height: CGFloat = 100 + (UIDevice.isMordenPhone ? 34 : 0)
        layer.frame = CGRect(x: 0, y: bounds.height-height, width: UIScreen.main.bounds.width, height: height)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.06).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 0.7, 0.85, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    private(set) lazy var editOptionsView: EditorEditOptionsView = {
        let view = EditorEditOptionsView(frame: .zero, config: config)
        view.delegate = self
        return view
    }()
    private(set) lazy var penToolView: EditorPenToolView = {
        let view = EditorPenToolView(frame: .zero, config: config)
        view.delegate = self
        view.isHidden = true
        return view
    }()
    private(set) lazy var cropToolView: EditorCropToolView = {
        let view = EditorCropToolView(frame: .zero)
        view.delegate = self
        view.isHidden = true
        return view
    }()
    private(set) lazy var mosaicToolView: EditorMosaicToolView = {
        let view = EditorMosaicToolView(frame: .zero, config: config)
        view.delegate = self
        view.isHidden = true
        return view
    }()
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 2
        view.backgroundColor = config.tintColor
        view.setTitle(BundleHelper.editorLocalizedString(key: "Done"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 10)
        return view
    }()
    
    private let config: ImageEditorController.PhotoConfig
    
    init(frame: CGRect, config: ImageEditorController.PhotoConfig) {
        self.config = config
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(topCoverLayer)
        layer.addSublayer(bottomCoverLayer)
        addSubview(editOptionsView)
        addSubview(penToolView)
        addSubview(cropToolView)
        addSubview(mosaicToolView)
        addSubview(doneButton)
        
        editOptionsView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(20)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(safeAreaLayoutGuide).offset(-14)
            } else {
                maker.bottom.equalToSuperview().offset(-14)
            }
            maker.height.equalTo(50)
        }
        penToolView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview().inset(20)
            maker.bottom.equalTo(editOptionsView.snp.top).offset(-20)
            maker.height.equalTo(20)
        }
        mosaicToolView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(penToolView)
        }
        doneButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(editOptionsView)
            maker.right.equalToSuperview().offset(-20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cropToolView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            if #available(iOS 11, *) {
                maker.height.equalTo(65 + safeAreaInsets.bottom)
            } else {
                maker.height.equalTo(65)
            }
        }
    }
}

// MARK: - EditorEditOptionsViewDelegate
extension EditorToolView: EditorEditOptionsViewDelegate {
    
    func editOptionsView(_ editOptionsView: EditorEditOptionsView, optionDidChange option: ImageEditorController.PhotoEditOption?) {
        delegate?.toolView(self, optionDidChange: option)
        
        guard let option = option else {
            penToolView.isHidden = true
            cropToolView.isHidden = true
            mosaicToolView.isHidden = true
            return
        }
        
        penToolView.isHidden = option != .pen
        cropToolView.isHidden = option != .crop
        mosaicToolView.isHidden = option != .mosaic
        
        switch option {
        case .crop:
            editOptionsView.isHidden = true
            topCoverLayer.isHidden = true
            doneButton.isHidden = true
        default:
            break
        }
    }
}

// MARK: - EditorPenToolViewDelegate
extension EditorToolView: EditorPenToolViewDelegate {
    
    func penToolView(_ penToolView: EditorPenToolView, colorDidChange idx: Int) {
        delegate?.toolView(self, colorDidChange: idx)
    }
    
    func penToolViewUndoButtonTapped(_ penToolView: EditorPenToolView) {
        delegate?.toolViewUndoButtonTapped(self)
    }
}

// MARK: - EditorCropToolViewDelegate
extension EditorToolView: EditorCropToolViewDelegate {
    
    func cropToolViewCancelButtonTapped(_ cropToolView: EditorCropToolView) {
        delegate?.toolViewCropCancelButtonTapped(self)
        editOptionsView.isHidden = false
        topCoverLayer.isHidden = false
        doneButton.isHidden = false
        cropToolView.isHidden = true
        editOptionsView.unselectButtons()
    }
    
    func cropToolViewDoneButtonTapped(_ cropToolView: EditorCropToolView) {
        delegate?.toolViewCropDoneButtonTapped(self)
        editOptionsView.isHidden = false
        topCoverLayer.isHidden = false
        doneButton.isHidden = false
        cropToolView.isHidden = true
        editOptionsView.unselectButtons()
    }
    
    func cropToolViewResetButtonTapped(_ cropToolView: EditorCropToolView) {
        delegate?.toolViewCropResetButtonTapped(self)
    }
}

// MARK: - EditorMosaicToolViewDelegate
extension EditorToolView: EditorMosaicToolViewDelegate {
    
    func mosaicToolView(_ mosaicToolView: EditorMosaicToolView, mosaicDidChange idx: Int) {
        delegate?.toolView(self, mosaicDidChange: idx)
    }
    
    func mosaicToolViewUndoButtonTapped(_ mosaicToolView: EditorMosaicToolView) {
        delegate?.toolViewUndoButtonTapped(self)
    }
}

// MARK: - ResponseTouch
extension EditorToolView: ResponseTouch {
    
    @discardableResult
    func responseTouch(_ point: CGPoint) -> Bool {
        let subViews = [editOptionsView, penToolView, cropToolView, mosaicToolView].filter{ !$0.isHidden }
        for subView in subViews {
            let viewPoint = point.subtraction(with: subView.frame.origin)
            if let subView = subView as? ResponseTouch, subView.responseTouch(viewPoint) {
                return true
            }
        }
        let doneFrame = doneButton.frame.bigger(.init(top: 10, left: 20, bottom: 20, right: 20))
        if doneFrame.contains(point) {
            delegate?.toolViewDoneButtonTapped(self)
            return true
        }
        return false
    }
}
