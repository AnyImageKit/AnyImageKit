//
//  SliderCollectionCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/5.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class SliderCollectionCell: UICollectionViewCell {
    
    private lazy var dotView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 2.5
        return view
    }()
    private lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
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
        contentView.addSubview(dotView)
        contentView.addSubview(lineView)
    }
    
    func config(size: CGSize, highlight: Bool, hiddenDot: Bool, isRegular: Bool) {
        dotView.isHidden = hiddenDot
        lineView.backgroundColor = highlight ? .white : .color(hex: 0xB5B5B5)
        
        if isRegular {
            dotView.snp.remakeConstraints { make in
                make.trailing.equalTo(lineView.snp.leading).offset(-8)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(5)
            }
            lineView.snp.remakeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.size.equalTo(size)
            }
        } else {
            dotView.snp.remakeConstraints { make in
                make.bottom.equalTo(lineView.snp.top).offset(-8)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(5)
            }
            lineView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.size.equalTo(size)
            }
        }
    }
}
