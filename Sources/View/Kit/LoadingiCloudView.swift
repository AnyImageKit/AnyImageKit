//
//  LoadingiCloudView.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/10/14.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class LoadingiCloudView: UIView {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: BundleHelper.image(named: "iCloud"))
        return view
    }()
    
    private lazy var tipLabel: UILabel = {
        let view = UILabel()
        view.text = BundleHelper.localizedString(key: "Downloading from iCloud")
        view.textColor = PhotoManager.shared.config.theme.textColor
        view.font = UIFont.systemFont(ofSize: 11)
        return view
    }()
    
    private lazy var progressLabel: UILabel = {
        let view = UILabel()
        view.text = "0%"
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 11)
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
        addSubview(imageView)
        addSubview(tipLabel)
        addSubview(progressLabel)
        
        imageView.snp.makeConstraints { (maker) in
            maker.top.left.bottom.equalToSuperview()
            maker.width.equalTo(imageView.snp.height)
        }
        tipLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(imageView.snp.right).offset(5)
            maker.centerY.equalToSuperview()
        }
        progressLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(tipLabel.snp.right).offset(1)
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
    }
}

// MARK: - Public function
extension LoadingiCloudView {
    
    public func reset() {
        setProgress(0)
        isHidden = true
    }
    
    public func setProgress(_ progress: Double) {
        progressLabel.text = "\(Int(progress * 100))%"
    }
    
    public func setLabelColor(_ color: UIColor) {
        tipLabel.textColor = color
        progressLabel.textColor = color
    }
}
