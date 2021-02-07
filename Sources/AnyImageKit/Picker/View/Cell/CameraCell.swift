//
//  CameraCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/21.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class CameraCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = BundleHelper.image(named: "Camera", module: .picker)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.color(hex: 0xDEDFE0)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(self.snp.width).multipliedBy(0.5)
        }
    }
}
