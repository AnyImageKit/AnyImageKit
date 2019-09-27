//
//  PhotoGIFPreviewCell.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class PhotoGIFPreviewCell: UICollectionViewCell {

    /// 显示图像
    public let imageView = AnimatedImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.contentMode = .center
        imageView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
    
}
