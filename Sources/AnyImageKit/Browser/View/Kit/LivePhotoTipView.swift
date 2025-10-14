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
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 6
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(label)
        imageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(4)
            maker.centerY.equalToSuperview()
        }
        label.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(4).priority(.high)
            maker.right.equalToSuperview().offset(-4)
            maker.centerY.equalToSuperview()
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension LivePhotoTipView: BrowserOptionsConfigurable {
    
    func update(options: BrowserOptionsInfo) {
        let color = options.theme[color: .tipsText]
        label.textColor = color
        label.text = options.theme[string: .livePhoto]
        imageView.tintColor = color
        imageView.image = options.theme[icon: .livePhoto]
        backgroundColor = options.theme[color: .background].withAlphaComponent(0.7)
        updateChildrenConfigurable(options: options)
        
        options.theme.labelConfiguration[.livePhotoMark]?.configuration(label)
    }
}
