//
//  FilterCollectionCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/5.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class FilterCollectionCell: UICollectionViewCell {
    
    private lazy var dotView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 2.5
        return view
    }()
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private let guide = UILayoutGuide()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(dotView)
        contentView.addSubview(imageView)
        contentView.addLayoutGuide(guide)
    }
    
    func config(size: CGSize, image: UIImage, hiddenDot: Bool, isRegular: Bool) {
        dotView.isHidden = hiddenDot
        imageView.image = image
        
        if isRegular {
            guide.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalTo(imageView.snp.leading)
                make.centerY.equalToSuperview()
                make.height.equalTo(10)
            }
            dotView.snp.remakeConstraints { make in
                make.centerX.equalTo(guide)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(5)
            }
            imageView.snp.remakeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.size.equalTo(size)
            }
        } else {
            guide.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.bottom.equalTo(imageView.snp.top)
                make.centerX.equalToSuperview()
                make.width.equalTo(10)
            }
            dotView.snp.remakeConstraints { make in
                make.centerY.equalTo(guide)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(5)
            }
            imageView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.size.equalTo(size)
            }
        }
    }
}
