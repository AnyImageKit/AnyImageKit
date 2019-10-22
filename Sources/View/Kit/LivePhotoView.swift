//
//  LivePhotoView.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/10/22.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class LivePhotoView: UIView {

    private lazy var imageView: UIImageView = {
        let image = BundleHelper.image(named: "LivePhoto", style: PhotoManager.shared.config.theme.style)
        let view = UIImageView(image: image)
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.text = BundleHelper.localizedString(key: "Live photo")
        let color = ColorHelper.createByStyle(light: UIColor.color(hex: 666666), dark: UIColor.color(hex: 0x999999))
        view.textColor = color
        view.font = UIFont.systemFont(ofSize: 12)
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
