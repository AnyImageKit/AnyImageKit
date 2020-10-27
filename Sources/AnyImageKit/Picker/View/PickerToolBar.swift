//
//  PickerToolBar.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PickerToolBar: UIView {
    
    private(set) lazy var contentView = UIView(frame: .zero)
    
    private(set) lazy var leftButton: UIButton = {
        let view = UIButton(type: .custom)
        view.backgroundColor = UIColor.clear
        view.setTitleColor(options.theme.textColor, for: .normal)
        view.setTitleColor(options.theme.textColor.withAlphaComponent(0.3), for: .disabled)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private(set) lazy var originalButton: OriginalButton = {
        let view = OriginalButton(frame: .zero, options: options)
        return view
    }()
    
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.backgroundColor = options.theme.mainColor
        let normal = UIColor.create(style: options.theme.style,
                                    light: .white,
                                    dark: options.theme.textColor)
        let disabled = UIColor.create(style: options.theme.style,
                                      light: normal.withAlphaComponent(0.7),
                                      dark: normal.withAlphaComponent(0.3))
        view.setTitleColor(normal, for: .normal)
        view.setTitleColor(disabled, for: .disabled)
        view.setTitle(BundleHelper.pickerLocalizedString(key: "Done"), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private(set) lazy var permissionLimitedView: PermissionLimitedView = {
        let view = PermissionLimitedView(options: options)
        view.isHidden = true
        return view
    }()
    
    let limitedViewHeight: CGFloat = 56
    let toolBarHeight: CGFloat = 56
    
    private let style: Style
    private let options: PickerOptionsInfo
    
    init(style: Style, options: PickerOptionsInfo) {
        self.style = style
        self.options = options
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = options.theme.toolBarColor
        switch style {
        case .picker:
            addSubview(permissionLimitedView)
            permissionLimitedView.snp.makeConstraints { maker in
                maker.top.left.right.equalToSuperview()
                maker.height.equalTo(limitedViewHeight)
            }
            leftButton.setTitle(BundleHelper.pickerLocalizedString(key: "Preview"), for: .normal)
        case .preview:
            leftButton.setTitle(BundleHelper.pickerLocalizedString(key: "Edit"), for: .normal)
        }
        
        addSubview(contentView)
        contentView.addSubview(leftButton)
        contentView.addSubview(originalButton)
        contentView.addSubview(doneButton)
        
        contentView.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(toolBarHeight)
        }
        leftButton.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(15)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(30)
        }
        originalButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(30)
        }
        doneButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-15)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGSize(width: 60, height: 30))
        }
    }
}

// MARK: - Function
extension PickerToolBar {
    
    func setEnable(_ enable: Bool) {
        leftButton.isEnabled = enable
        doneButton.isEnabled = enable
        doneButton.backgroundColor = enable ? options.theme.mainColor : options.theme.buttonDisableColor
    }
    
    func showLimitedView() {
        permissionLimitedView.isHidden = false
        contentView.snp.updateConstraints { update in
            update.top.equalToSuperview().offset(limitedViewHeight)
        }
    }
}

extension PickerToolBar {
    
    enum Style {
        case picker
        case preview
    }
}
