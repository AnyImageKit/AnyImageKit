//
//  EditorCropToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorCropToolViewDelegate: class {
    
    func cropToolViewCancelButtonTapped(_ cropToolView: EditorCropToolView)
    func cropToolViewDoneButtonTapped(_ cropToolView: EditorCropToolView)
    func cropToolViewResetButtonTapped(_ cropToolView: EditorCropToolView)
}

final class EditorCropToolView: UIView {
    
    weak var delegate: EditorCropToolViewDelegate?
    
    private(set) lazy var cancelButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "XMark"), for: .normal)
        return view
    }()
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "CheckMark"), for: .normal)
        return view
    }()
    private(set) lazy var resetbutton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle(BundleHelper.editorLocalizedString(key: "Reset"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    private lazy var line: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let content = UILayoutGuide()
        addLayoutGuide(content)
        addSubview(line)
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(resetbutton)
        
        content.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(65)
        }
        line.snp.makeConstraints { (maker) in
            maker.top.left.right.equalTo(content)
            maker.height.equalTo(0.5)
        }
        cancelButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(content).offset(20)
            maker.centerY.equalTo(content)
            maker.width.height.equalTo(40)
        }
        doneButton.snp.makeConstraints { (maker) in
            maker.right.equalTo(content).offset(-20)
            maker.centerY.equalTo(content)
            maker.width.height.equalTo(40)
        }
        resetbutton.snp.makeConstraints { (maker) in
            maker.top.bottom.equalTo(content)
            maker.centerX.equalTo(content)
            maker.width.equalTo(60)
        }
    }
}

// MARK: - ResponseTouch
extension EditorCropToolView: ResponseTouch {
    
    func responseTouch(_ point: CGPoint) -> Bool {
        for (idx, view) in [cancelButton, doneButton, resetbutton].enumerated() {
            let frame = view.frame.bigger(.init(top: 10, left: 15, bottom: 30, right: 30))
            if frame.contains(point) {
                switch idx {
                case 0: // 取消按钮
                    delegate?.cropToolViewCancelButtonTapped(self)
                case 1: // 完成按钮
                    delegate?.cropToolViewDoneButtonTapped(self)
                case 2: // 重置按钮
                    delegate?.cropToolViewResetButtonTapped(self)
                default:
                    break
                }
                return true
            }
        }
        return false
    }
}
