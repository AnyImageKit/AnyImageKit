//
//  OriginalButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
/*
final class OriginalButton: UIButton {
    
    private lazy var checkImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.isUserInteractionEnabled = false
        view.text = BundleHelper.localizedString(key: "ORIGINAL_IMAGE", module: .picker)
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        accessibilityLabel = BundleHelper.localizedString(key: "ORIGINAL_IMAGE", module: .picker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(checkImageView)
        addSubview(label)
        checkImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGSize(width: 16, height: 16))
        }
        label.snp.makeConstraints { maker in
            maker.left.equalTo(checkImageView.snp.right).offset(8)
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
    }
}
 
// MARK: - PickerOptionsConfigurable
extension OriginalButton: PickerOptionsInfoConfigurable {
    
    func update(options: PickerOptionsInfo) {
        setImage(options.theme[icon: .checkOn], for: .selected)
        setImage(options.theme[icon: .checkOff], for: .normal)
        checkImageView.image = options.theme[icon: .checkOff]
        checkImageView.tintColor = options.theme[color: .main]
        label.textColor = options.theme[color: .text]
        updateChildConfigurable(options: options)
    }
}
*/
