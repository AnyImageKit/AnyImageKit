//
//  GIFView.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/10/16.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class GIFView: UIView {

    private lazy var gifLabel: UILabel = {
        let view = UILabel()
        view.text = "GIF"
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return view
    }()
    private lazy var gifCoverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: self.bounds.height-20, width: self.bounds.width, height: 20)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gifCoverLayer.frame = CGRect(x: 0, y: self.bounds.height-20, width: self.bounds.width, height: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(gifCoverLayer)
        addSubview(gifLabel)
        
        gifLabel.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(8)
            maker.height.equalTo(15)
        }
    }
}
