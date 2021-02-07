//
//  EditorToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class EditorToolView: UIView {
    
    var currentOption: EditorPhotoToolOption? {
        editOptionsView.currentOption
    }
    
    private(set) lazy var topCoverView: GradientView = {
        let view = GradientView(frame: .zero)
        view.layer.colors = [
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.06).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
        ]
        view.layer.locations = [0, 0.7, 0.85, 1]
        view.layer.startPoint = CGPoint(x: 0.5, y: 0)
        view.layer.endPoint = CGPoint(x: 0.5, y: 1)
        return view
    }()
    private(set) lazy var bottomCoverView: GradientView = {
        let view = GradientView(frame: .zero)
        view.layer.colors = [
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.06).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
        ]
        view.layer.locations = [0, 0.7, 0.85, 1]
        view.layer.startPoint = CGPoint(x: 0.5, y: 1)
        view.layer.endPoint = CGPoint(x: 0.5, y: 0)
        return view
    }()
    
    private(set) lazy var editOptionsView: EditorEditOptionsView = {
        let view = EditorEditOptionsView(frame: .zero, options: options)
        view.delegate = self
        return view
    }()
    private(set) lazy var penToolView: EditorPenToolView = {
        let view = EditorPenToolView(frame: .zero, options: options)
        view.delegate = self
        view.isHidden = true
        return view
    }()
    private(set) lazy var cropToolView: EditorCropToolView = {
        let view = EditorCropToolView(frame: .zero, options: options)
        view.delegate = self
        view.isHidden = true
        return view
    }()
    private(set) lazy var mosaicToolView: EditorMosaicToolView = {
        let view = EditorMosaicToolView(frame: .zero, options: options)
        view.delegate = self
        view.isHidden = true
        return view
    }()
    private(set) lazy var doneButton: UIButton = {
        let view = BigButton(moreInsets: UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20))
        view.layer.cornerRadius = 2
        view.backgroundColor = options.tintColor
        view.setTitle(BundleHelper.localizedString(key: "DONE", module: .core), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 10)
        view.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return view
    }()
    
    /// Context
    private let context: PhotoEditorContext
    /// 配置项
    private var options: EditorPhotoOptionsInfo {
        return context.options
    }
    
    init(frame: CGRect, context: PhotoEditorContext) {
        self.context = context
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(topCoverView)
        addSubview(bottomCoverView)
        addSubview(editOptionsView)
        addSubview(penToolView)
        addSubview(cropToolView)
        addSubview(mosaicToolView)
        addSubview(doneButton)
        
        topCoverView.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                maker.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(120)
            } else {
                maker.height.equalTo(120)
            }
        }
        bottomCoverView.snp.makeConstraints { maker in
            maker.bottom.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                maker.top.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-100)
            } else {
                maker.height.equalTo(100)
            }
        }
        editOptionsView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            if #available(iOS 11.0, *) {
                maker.bottom.equalTo(safeAreaLayoutGuide).offset(-14)
            } else {
                maker.bottom.equalToSuperview().offset(-14)
            }
            maker.height.equalTo(50)
        }
        penToolView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview().inset(20)
            maker.bottom.equalTo(editOptionsView.snp.top).offset(-10)
            maker.height.equalTo(30)
        }
        mosaicToolView.snp.makeConstraints { maker in
            maker.edges.equalTo(penToolView)
        }
        cropToolView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(editOptionsView).offset(15)
            maker.height.equalTo(40+60)
        }
        doneButton.snp.makeConstraints { maker in
            maker.centerY.equalTo(editOptionsView)
            maker.right.equalToSuperview().offset(-20)
        }
    }
}

// MARK: - Public
extension EditorToolView {
    
    public func selectFirstItemIfNeeded() {
        editOptionsView.selectFirstItemIfNeeded()
    }
}

// MARK: - Target
extension EditorToolView {
    
    @objc private func doneButtonTapped() {
        context.action(.done)
    }
}

// MARK: - EditorEditOptionsViewDelegate
extension EditorToolView: EditorEditOptionsViewDelegate {
    
    func editOptionsView(_ editOptionsView: EditorEditOptionsView, optionDidChange option: EditorPhotoToolOption?) {
        context.action(.toolOptionChanged(option))
        
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
            topCoverView.isHidden = true
            doneButton.isHidden = true
            if let option = options.cropOptions.first, cropToolView.currentOption == nil {
                cropToolView.currentOption = option
            }
        default:
            break
        }
    }
}

// MARK: - EditorPenToolViewDelegate
extension EditorToolView: EditorPenToolViewDelegate {
    
    func penToolView(_ penToolView: EditorPenToolView, colorDidChange color: UIColor) {
        context.action(.penChangeColor(color))
    }
    
    func penToolViewUndoButtonTapped(_ penToolView: EditorPenToolView) {
        context.action(.penUndo)
    }
}

// MARK: - EditorMosaicToolViewDelegate
extension EditorToolView: EditorMosaicToolViewDelegate {
    
    func mosaicToolView(_ mosaicToolView: EditorMosaicToolView, mosaicDidChange idx: Int) {
        context.action(.mosaicChangeImage(idx))
    }
    
    func mosaicToolViewUndoButtonTapped(_ mosaicToolView: EditorMosaicToolView) {
        context.action(.mosaicUndo)
    }
}

// MARK: - EditorCropToolViewDelegate
extension EditorToolView: EditorCropToolViewDelegate {
    
    func cropToolView(_ toolView: EditorCropToolView, didClickCropOption option: EditorCropOption) {
        context.action(.cropUpdateOption(option))
    }
    
    func cropToolViewCancelButtonTapped(_ cropToolView: EditorCropToolView) {
        context.action(.cropCancel)
        editOptionsView.isHidden = false
        topCoverView.isHidden = false
        doneButton.isHidden = false
        cropToolView.isHidden = true
        editOptionsView.unselectButtons()
    }
    
    func cropToolViewDoneButtonTapped(_ cropToolView: EditorCropToolView) {
        context.action(.cropDone)
        editOptionsView.isHidden = false
        topCoverView.isHidden = false
        doneButton.isHidden = false
        cropToolView.isHidden = true
        editOptionsView.unselectButtons()
    }
    
    func cropToolViewResetButtonTapped(_ cropToolView: EditorCropToolView) {
        context.action(.cropReset)
    }
}

// MARK: - Event
extension EditorToolView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || !isUserInteractionEnabled || alpha < 0.01 {
            return nil
        }
        let subViews = [editOptionsView, penToolView, cropToolView, mosaicToolView, doneButton]
        for subView in subViews {
            if let hitView = subView.hitTest(subView.convert(point, from: self), with: event) {
                return hitView
            }
        }
        return nil
    }
}
