//
//  ToolCollectionCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/22.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class ToolCollectionCell: UICollectionViewCell {
    
    func config(view: UIView) {
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        contentView.addSubview(view)
        view.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
