//
//  TextImageView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/10.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class TextImageView: UIView {
    
    let text: String
    let image: UIImage
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: image)
        return view
    }()
    
    private(set) var isSelected: Bool = false
    
    init(frame: CGRect, text: String, image: UIImage) {
        self.text = text
        self.image = image
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(10)
        }
    }
}

extension TextImageView {
    
    public func setSelected(_ selected: Bool) {
        isSelected = selected
        layer.borderWidth = selected ? 0.5 : 0.0
        layer.borderColor = UIColor.white.cgColor
    }
}
