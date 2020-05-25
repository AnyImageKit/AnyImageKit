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
        view.accessibilityLabel = BundleHelper.editorLocalizedString(key: "Cancel")
        view.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "CheckMark"), for: .normal)
        view.accessibilityLabel = BundleHelper.editorLocalizedString(key: "Done")
        view.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var resetbutton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle(BundleHelper.editorLocalizedString(key: "Reset"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.addTarget(self, action: #selector(resetButtonTapped(_:)), for: .touchUpInside)
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

// MARK: - Target
extension EditorCropToolView {
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        delegate?.cropToolViewCancelButtonTapped(self)
    }
    
    @objc private func resetButtonTapped(_ sender: UIButton) {
        delegate?.cropToolViewResetButtonTapped(self)
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        delegate?.cropToolViewDoneButtonTapped(self)
    }
}

// MARK: - Event
extension EditorCropToolView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || !isUserInteractionEnabled || alpha < 0.01 {
            return nil
        }
        for subView in [cancelButton, doneButton, resetbutton] {
            if let hitView = subView.hitTest(subView.convert(point, from: self), with: event) {
                return hitView
            }
        }
        return nil
    }
}
