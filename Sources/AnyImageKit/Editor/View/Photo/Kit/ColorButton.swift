//
//  ColorButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/10.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class ColorButton: UIButton {
    
    private(set) lazy var colorView: UIView = {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        view.backgroundColor = color
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.layer.cornerRadius = size/2
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

