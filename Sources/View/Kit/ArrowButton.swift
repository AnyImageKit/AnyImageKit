//
//  ArrowButton.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/18.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class ArrowButton: UIControl {

    private(set) var isOpen = false
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.text = "最近项目"
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return view
    }()
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = BundleHelper.image(named: "Arrow")
        return view
    }()
    private lazy var contentView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
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
        contentView.layer.cornerRadius = contentView.bounds.height * 0.5
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.contentView.addSubview(label)
        contentView.contentView.addSubview(imageView)
        contentView.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.centerX.equalToSuperview()
            maker.height.equalTo(35)
        }
        label.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(10)
        }
        imageView.snp.makeConstraints { (maker) in
            maker.left.equalTo(label.snp.right).offset(5)
            maker.right.equalToSuperview().offset(-6)
            maker.width.height.equalTo(20)
            maker.centerY.equalToSuperview()
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        isOpen.toggle()
        UIView.animate(withDuration: 0.2) {
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(self.isOpen ? Double.pi : 0))
            self.layoutIfNeeded()
        }
    }
    
    public func setTitle(_ title: String) {
        if isOpen {
            isOpen = false
        }
        UIView.animate(withDuration: 0.2) {
            self.label.text = title
            self.imageView.transform = CGAffineTransform(rotationAngle: 0)
            self.layoutIfNeeded()
        }
    }
}
