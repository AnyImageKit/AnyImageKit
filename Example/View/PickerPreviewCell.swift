//
//  PickerPreviewCell.swift
//  Example
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class PickerPreviewCell: UICollectionViewCell {
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
            view.textColor = .label
        } else {
            view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            view.textColor = .black
        }
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return view
    }()
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { maker in
            maker.top.left.equalToSuperview().offset(4)
        }
    }
}
