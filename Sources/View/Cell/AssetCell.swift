//
//  AssetCell.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class AssetCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
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
        imageView.snp.makeConstraints { maker in
            maker.edges.equalTo(contentView.snp.edges)
        }
    }
}

extension AssetCell {
    
    var image: UIImage? {
        return imageView.image
    }
}

extension AssetCell {
    
    func setContent(_ asset: Asset) {
        let width = imageView.frame.width * UIScreen.main.nativeScale
        PhotoManager.shared.requestImage(for: asset.asset, width: width, completion: { [weak self] (image, info, isDegraded) in
            guard let self = self else { return }
            print("image did Updated,image=\(image)")
            self.imageView.image = image
        })
        
    }
}
