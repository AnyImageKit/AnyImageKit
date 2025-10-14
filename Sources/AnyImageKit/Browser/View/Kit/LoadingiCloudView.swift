//
//  LoadingiCloudView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/14.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final public class LoadingiCloudView: UIView {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.tintColor = UIColor.white
        return view
    }()
    
    private lazy var tipsLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    
    private lazy var progressLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = "0%"
        view.textColor = UIColor.white 
        view.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        return view
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 6
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(tipsLabel)
        addSubview(progressLabel)
        
        imageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(4)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(20)
        }
        tipsLabel.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(4).priority(.high)
            maker.centerY.equalToSuperview()
        }
        progressLabel.snp.makeConstraints { maker in
            maker.left.equalTo(tipsLabel.snp.right).offset(2)
            maker.right.equalToSuperview().offset(-4)
            maker.centerY.equalToSuperview()
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension LoadingiCloudView: BrowserOptionsConfigurable {
    
    public func update(options: BrowserOptionsInfo) {
        let color = options.theme[color: .text]
        progressLabel.textColor = color
        tipsLabel.textColor = color
        tipsLabel.text = options.theme[string: .browserDownloadingFromiCloud]
        imageView.tintColor = color
        imageView.image = options.theme[icon: .iCloud]
        backgroundColor = options.theme[color: .background].withAlphaComponent(0.7)
        updateChildrenConfigurable(options: options)
        
        updateChildrenConfigurable(options: options)
        
        options.theme.labelConfiguration[.loadingFromiCloudTips]?.configuration(tipsLabel)
        options.theme.labelConfiguration[.loadingFromiCloudProgress]?.configuration(progressLabel)
    }
    
}

// MARK: - Function
extension LoadingiCloudView {
    
    public func reset() {
        setProgress(0)
        isHidden = true
    }
    
    public func setProgress(_ progress: Double) {
        progressLabel.text = "\(Int(progress * 100))%"
    }
}
