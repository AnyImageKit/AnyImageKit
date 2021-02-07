//
//  LivePhotoTipView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/22.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class LivePhotoTipView: UIView {

    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = BundleHelper.localizedString(key: "LIVE_PHOTO", module: .core)
        view.font = UIFont.systemFont(ofSize: 13)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(label)
        imageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(5)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(20)
        }
        label.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(5)
            maker.right.equalToSuperview().offset(-5)
            maker.centerY.equalToSuperview()
        }
    }
    
    func updateOptions(_ options: PickerOptionsInfo) {
        imageView.image = BundleHelper.image(named: "LivePhoto", style: options.theme.style, module: .picker)
        let color = UIColor.create(style: options.theme.style,
                                   light: UIColor.color(hex: 0x666666),
                                   dark: UIColor.color(hex: 0x999999))
        label.textColor = color
        backgroundColor = options.theme.backgroundColor.withAlphaComponent(0.7)
    }

}
