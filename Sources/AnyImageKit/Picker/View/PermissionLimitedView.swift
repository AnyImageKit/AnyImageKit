//
//  PermissionLimitedView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/9/22.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PermissionLimitedView: UIView {

    private lazy var warningImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = BundleHelper.image(named: "Warning", style: options.theme.style, module: .picker)
        return view
    }()
    
    private lazy var tipsLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.numberOfLines = 2
        view.textColor = options.theme.textColor
        view.font = UIFont.systemFont(ofSize: 14)
        view.text = BundleHelper.localizedString(key: "LIMITED_PHOTOS_PERMISSION_TIPS", module: .picker)
        return view
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = BundleHelper.image(named: "ArrowRight", style: options.theme.style, module: .picker)
        return view
    }()
    
    private(set) lazy var limitedButton: UIButton = {
        let view = UIButton(type: .custom)
        return view
    }()
    
    private let options: PickerOptionsInfo
    
    init(options: PickerOptionsInfo) {
        self.options = options
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(warningImageView)
        addSubview(tipsLabel)
        addSubview(arrowImageView)
        addSubview(limitedButton)
        
        warningImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(15)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(25)
        }
        tipsLabel.snp.makeConstraints { maker in
            maker.left.equalTo(warningImageView.snp.right).offset(10)
            maker.centerY.equalToSuperview()
        }
        arrowImageView.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-15)
            maker.centerY.equalToSuperview()
        }
        limitedButton.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
}
