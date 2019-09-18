//
//  PhotoPreviewToolBar.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class PhotoPreviewToolBar: UIView {

    private(set) lazy var editButton: UIButton = {
        let view = UIButton(type: .custom)
        view.backgroundColor = UIColor.clear
        view.setTitle(BundleHelper.localizedString(key: "Edit"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    private(set) lazy var originalButton: OriginalButton = {
        let view = OriginalButton(frame: .zero)
        return view
    }()
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.backgroundColor = UIColor.wechat_green
        view.setTitleColor(UIColor.white, for: .normal)
        view.setTitle(BundleHelper.localizedString(key: "Done"), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.color(hex: 0x5C5C5C)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let contentView = UILayoutGuide()
        addLayoutGuide(contentView)
        addSubview(editButton)
        addSubview(originalButton)
        addSubview(doneButton)
        contentView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(50)
        }
        editButton.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(15)
            maker.centerY.equalTo(contentView)
            maker.height.equalTo(30)
        }
        originalButton.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.centerY.equalTo(contentView)
            maker.height.equalTo(30)
        }
        doneButton.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-15)
            maker.centerY.equalTo(contentView)
            maker.size.equalTo(CGSize(width: 60, height: 30))
        }
    }

    public func hiddenEditAndOriginalButton(_ hidden: Bool) {
        editButton.isHidden = hidden
        originalButton.isHidden = hidden
    }
    
}
