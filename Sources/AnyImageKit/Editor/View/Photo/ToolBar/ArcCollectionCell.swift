//
//  ArcCollectionCell.swift
//  AnyImageKit
//
//  Created by Ray on 2022/2/4.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class ArcCollectionCell: UICollectionViewCell {
    
    private lazy var dotView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 2.5
        return view
    }()
    private let guide = UILayoutGuide()
    
     var customView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(dotView)
        contentView.addLayoutGuide(guide)
    }
    
    func config(view: UIView, size: CGSize, isRegular: Bool, hiddenDot: Bool) {
        dotView.isHidden = hiddenDot
        if view.superview != nil {
            view.removeFromSuperview()
        }
        if customView?.window == nil {
            customView?.removeFromSuperview()
        }
        contentView.addSubview(view)
        customView = view
        
        if isRegular {
            guide.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalTo(view.snp.leading)
                make.height.equalTo(10)
            }
            dotView.snp.remakeConstraints { make in
                make.centerX.equalTo(guide)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(5)
            }
            view.snp.remakeConstraints { make in
                make.top.bottom.trailing.equalToSuperview()
                make.size.equalTo(size)
            }
        } else {
            guide.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.bottom.equalTo(view.snp.top)
                make.width.equalTo(10)
            }
            dotView.snp.remakeConstraints { make in
                make.centerY.equalTo(guide)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(5)
            }
            view.snp.remakeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.size.equalTo(size)
            }
        }
    }
}
