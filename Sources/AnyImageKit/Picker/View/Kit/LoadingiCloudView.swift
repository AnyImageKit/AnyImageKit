//
//  LoadingiCloudView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/14.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class LoadingiCloudView: UIView {
    
    private lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        view.backgroundColor = UIColor.color(hex: 0xA7A7A7).withAlphaComponent(0.7)
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let image = BundleHelper.image(named: "iCloud", module: .picker)
        let view = UIImageView(image: image)
        return view
    }()
    
    private lazy var tipLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = BundleHelper.localizedString(key: "DOWNLOADING_FROM_ICLOUD", module: .picker)
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 11)
        return view
    }()
    
    private lazy var progressLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = "0%"
        view.textColor = UIColor.white 
        view.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(effectView)
        addSubview(imageView)
        addSubview(tipLabel)
        addSubview(progressLabel)
        
        effectView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(5)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(20)
        }
        tipLabel.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(5)
            maker.centerY.equalToSuperview()
        }
        progressLabel.snp.makeConstraints { maker in
            maker.left.equalTo(tipLabel.snp.right).offset(3)
            maker.right.equalToSuperview().offset(-5)
            maker.centerY.equalToSuperview()
        }
    }
}

// MARK: - function
extension LoadingiCloudView {
    
    func reset() {
        setProgress(0)
        isHidden = true
    }
    
    func setProgress(_ progress: Double) {
        progressLabel.text = "\(Int(progress * 100))%"
    }
}
