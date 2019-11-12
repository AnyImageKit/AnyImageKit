//
//  PhotoCropToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol PhotoCropToolViewDelegate: class {
    
    func cropToolViewCancelButtonTapped(_ cropToolView: PhotoCropToolView)
    func cropToolViewDoneButtonTapped(_ cropToolView: PhotoCropToolView)
    func cropToolViewResetButtonTapped(_ cropToolView: PhotoCropToolView)
}

final class PhotoCropToolView: UIView {
    
    weak var delegate: PhotoCropToolViewDelegate?
    
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
        let view = UIView()
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
extension PhotoCropToolView: ResponseTouch {
    
    func responseTouch(_ point: CGPoint) -> Bool {
        for (idx, view) in [cancelButton, doneButton, resetbutton].enumerated() {
            let frame = view.frame.bigger(.init(top: 10, left: 15, bottom: 30, right: 30))
            if frame.contains(point) {
                switch idx {
                case 0:
                    delegate?.cropToolViewCancelButtonTapped(self)
                case 1:
                    delegate?.cropToolViewDoneButtonTapped(self)
                case 2:
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
