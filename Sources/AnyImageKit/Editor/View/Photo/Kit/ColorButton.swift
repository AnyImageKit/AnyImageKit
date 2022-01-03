//
//  ColorButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/10.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class ColorButton: UIButton {
    
    private(set) lazy var colorView: UIButton = {
        let view = UIButton(type: .custom)
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        view.backgroundColor = color
        return view
    }()
    
    private let size: CGFloat
    private let color: UIColor
    private let borderWidth: CGFloat
    private let borderColor: UIColor
    
    init(tag: Int, size: CGFloat, color: UIColor, borderWidth: CGFloat, borderColor: UIColor) {
        self.size = size
        self.color = color
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        super.init(frame: .zero)
        self.tag = tag
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.borderWidth = isSelected ? borderWidth * 1.5 : borderWidth
        colorView.layer.borderColor = borderColor.cgColor
        colorView.layer.cornerRadius = colorView.bounds.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(colorView)
        colorView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(size)
        }
    }
}

