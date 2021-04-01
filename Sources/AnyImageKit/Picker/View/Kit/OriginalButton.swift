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
                let image = BundleHelper.image(named: "CheckOn", module: .picker)
                checkImageView.image = image?.withRenderingMode(.alwaysTemplate)
            } else {
                let image = BundleHelper.image(named: "CheckOff", module: .picker)
                checkImageView.image = image
            }
        }
    }
    
    private lazy var checkImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.isUserInteractionEnabled = false
        let image = BundleHelper.image(named: "CheckOff", module: .picker)
        view.image = image
        view.tintColor = options.theme.mainColor
        return view
    }()
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = BundleHelper.localizedString(key: "ORIGINAL_IMAGE", module: .picker)
        view.textColor = options.theme.textColor
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
