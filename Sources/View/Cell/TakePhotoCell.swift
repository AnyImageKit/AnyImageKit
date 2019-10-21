//
//  TakePhotoCell.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/10/21.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class TakePhotoCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.yellow
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
    }
}
