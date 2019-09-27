//
//  PhotoGIFPreviewCell.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class PhotoGIFPreviewCell: PreviewCell {
    
    /// 取图片适屏size
    override var fitSize: CGSize {
        guard let image = imageView.image else { return CGSize.zero }
        return image.size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        imageView.removeFromSuperview()
        imageView = AnimatedImageView()
        imageView.contentMode = .scaleToFill
        scrollView.addSubview(imageView)
    }
}
