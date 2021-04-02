//
//  OriginalButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class OriginalButton: UIControl {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                checkImageView.image = options.theme[icon: .checkOn]
            } else {
                checkImageView.image = options.theme[icon: .checkOff]
            }
        }
    }
    
    private lazy var checkImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.image = options.theme[icon: .checkOff]
        view.tintColor = options.theme[color: .main]
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = BundleHelper.localizedString(key: "ORIGINAL_IMAGE", module: .picker)
        view.textColor = options.theme[color: .text]
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private let options: PickerOptionsInfo
    
    init(frame: CGRect, options: PickerOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
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
    
    @objc private func buttonTapped(_ sender: UIButton) {
        isSelected.toggle()
    }
}
