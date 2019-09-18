//
//  ArrowButton.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/18.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class ArrowButton: UIControl {
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = BundleHelper.image(named: "Arrow")
        return view
    }()
    
    private lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        effectView.layer.cornerRadius = effectView.bounds.height * 0.5
    }
    
    private func setupView() {
        addSubview(effectView)
        effectView.contentView.addSubview(label)
        effectView.contentView.addSubview(imageView)
        let height: CGFloat = 32
        effectView.snp.makeConstraints { (maker) in
            maker.height.equalTo(height)
            maker.edges.equalTo(snp.edges)
        }
        label.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(12)
        }
        imageView.snp.makeConstraints { (maker) in
            maker.left.equalTo(label.snp.right).offset(8)
            maker.right.equalToSuperview().offset(-6)
            maker.width.height.equalTo(20)
            maker.centerY.equalToSuperview()
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        isSelected.toggle()
        UIView.animate(withDuration: 0.2) {
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(self.isSelected ? Double.pi : 0))
            self.layoutIfNeeded()
        }
    }
    
    public func setTitle(_ title: String) {
        if isSelected {
            isSelected = false
        }
        UIView.animate(withDuration: 0.2) {
            self.label.text = title
            self.imageView.transform = CGAffineTransform(rotationAngle: 0)
            self.layoutIfNeeded()
        }
    }
}
