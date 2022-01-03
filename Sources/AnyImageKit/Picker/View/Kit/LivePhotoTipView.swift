//
//  LivePhotoTipView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/22.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class LivePhotoTipView: UIView {

    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
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
}

// MARK: - PickerOptionsConfigurable
extension LivePhotoTipView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        imageView.image = options.theme[icon: .livePhoto]
        let color = UIColor.create(style: options.theme.style,
                                   light: UIColor.color(hex: 0x666666),
                                   dark: UIColor.color(hex: 0x999999))
        label.textColor = color
        label.text = options.theme[string: .livePhoto]
        backgroundColor = options.theme[color: .background].withAlphaComponent(0.7)
        updateChildrenConfigurable(options: options)
        
        options.theme.labelConfiguration[.livePhotoMark]?.configuration(label)
    }
}
