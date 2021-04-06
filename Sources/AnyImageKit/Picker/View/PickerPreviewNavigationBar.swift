//
//  PickerPreviewNavigationBar.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PickerPreviewNavigationBar: UIView {
    
    private(set) lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        view.accessibilityLabel = BundleHelper.localizedString(key: "BACK", module: .core)
        return view
    }()
    private(set) lazy var selectButton: NumberCircleButton = {
        let view = NumberCircleButton(frame: .zero, style: .large)
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
        let contentView = UILayoutGuide()
        addLayoutGuide(contentView)
        addSubview(backButton)
        addSubview(selectButton)
        contentView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(44)
        }
        backButton.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(8)
            maker.centerY.equalTo(contentView)
            maker.width.height.equalTo(44)
        }
        selectButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-4)
            maker.centerY.equalTo(contentView)
            maker.width.height.equalTo(45)
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension PickerPreviewNavigationBar: PickerOptionsConfigurable {
    
    var childConfigurable: [PickerOptionsConfigurable] {
        return [selectButton]
    }
    
    func update(options: PickerOptionsInfo) {
        backgroundColor = options.theme[color: .toolBar].withAlphaComponent(0.95)
        backButton.setImage(options.theme[icon: .returnButton], for: .normal)
        updateChildConfigurable(options: options)
    }
}
