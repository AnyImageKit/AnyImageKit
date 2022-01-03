//
//  LoadingiCloudView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/14.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
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
        let view = UIImageView(frame: .zero)
        return view
    }()
    
    private lazy var tipsLabel: UILabel = {
        let view = UILabel(frame: .zero)
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
        addSubview(tipsLabel)
        addSubview(progressLabel)
        
        effectView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(5)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(20)
        }
        tipsLabel.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(5)
            maker.centerY.equalToSuperview()
        }
        progressLabel.snp.makeConstraints { maker in
            maker.left.equalTo(tipsLabel.snp.right).offset(3)
            maker.right.equalToSuperview().offset(-5)
            maker.centerY.equalToSuperview()
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension LoadingiCloudView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        tipsLabel.text = options.theme[string: .pickerDownloadingFromiCloud]
        imageView.image = options.theme[icon: .iCloud]
        updateChildrenConfigurable(options: options)
        
        options.theme.labelConfiguration[.loadingFromiCloudTips]?.configuration(tipsLabel)
        options.theme.labelConfiguration[.loadingFromiCloudProgress]?.configuration(progressLabel)
    }
}

// MARK: - Function
extension LoadingiCloudView {
    
    func reset() {
        setProgress(0)
        isHidden = true
    }
    
    func setProgress(_ progress: Double) {
        progressLabel.text = "\(Int(progress * 100))%"
    }
}
