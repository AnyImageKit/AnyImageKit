//
//  PhotoToolBar.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class PhotoToolBar: UIView {
    
    private lazy var backgroundView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        view.contentView.backgroundColor = PhotoManager.shared.config.theme.backgroundColor.withAlphaComponent(0.7)
        return view
    }()
    
    private(set) lazy var leftButton: UIButton = {
        let view = UIButton(type: .custom)
        view.backgroundColor = UIColor.clear
        view.setTitleColor(PhotoManager.shared.config.theme.textColor, for: .normal)
        view.setTitleColor(PhotoManager.shared.config.theme.textColor.withAlphaComponent(0.3), for: .disabled)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private(set) lazy var originalButton: OriginalButton = {
        let view = OriginalButton(frame: .zero)
        return view
    }()
    
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.backgroundColor = PhotoManager.shared.config.theme.mainColor
        let color = ColorHelper.createByStyle(light: .white, dark: PhotoManager.shared.config.theme.textColor)
        let disableColor = ColorHelper.createByStyle(light: color.withAlphaComponent(0.7), dark: color.withAlphaComponent(0.3))
        view.setTitleColor(color, for: .normal)
        view.setTitleColor(disableColor, for: .disabled)
        view.setTitle(BundleHelper.localizedString(key: "Done"), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private var style: Style = .picker
    
    init(style: Style) {
        super.init(frame: .zero)
        self.style = style
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        switch style {
        case .picker:
            addSubview(backgroundView)
            backgroundView.snp.makeConstraints { maker in
                maker.edges.equalToSuperview()
            }
            leftButton.setTitle(BundleHelper.localizedString(key: "Preview"), for: .normal)
        case .preview:
            backgroundColor = PhotoManager.shared.config.theme.toolBarColor
            leftButton.setTitle(BundleHelper.localizedString(key: "Edit"), for: .normal)
        }
        
        let contentView = UILayoutGuide()
        addLayoutGuide(contentView)
        addSubview(leftButton)
        addSubview(originalButton)
        addSubview(doneButton)
        
        contentView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(56)
        }
        leftButton.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(15)
            maker.centerY.equalTo(contentView)
            maker.height.equalTo(30)
        }
        originalButton.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.centerY.equalTo(contentView)
            maker.height.equalTo(30)
        }
        doneButton.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-15)
            maker.centerY.equalTo(contentView)
            maker.size.equalTo(CGSize(width: 60, height: 30))
        }
    }
}

// MARK: - Public function
extension PhotoToolBar {
    
    public func setEnable(_ enable: Bool) {
        leftButton.isEnabled = enable
        doneButton.isEnabled = enable
        doneButton.backgroundColor = enable ? PhotoManager.shared.config.theme.mainColor : PhotoManager.shared.config.theme.buttonDisableColor
    }
}

extension PhotoToolBar {
    
    enum Style {
        case picker
        case preview
    }
}
