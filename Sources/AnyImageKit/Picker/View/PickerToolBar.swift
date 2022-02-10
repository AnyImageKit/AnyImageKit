//
//  PickerToolBar.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class PickerToolBar: UIView {
    
    private var isLimited: Bool = false
    
    private(set) lazy var contentView = UIView(frame: .zero)
    
    private lazy var backgroundView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        return view
    }()
    
    private(set) lazy var leftButton: UIButton = {
        let view = UIButton(type: .custom)
        view.backgroundColor = UIColor.clear
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private(set) lazy var originalButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        let spacing: CGFloat = 8
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        return view
    }()
    
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private(set) lazy var permissionLimitedView: PermissionLimitedView = {
        let view = PermissionLimitedView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    let limitedViewHeight: CGFloat = 56
    let toolBarHeight: CGFloat = 56
    
    private let style: Style
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        switch style {
        case .picker:
            addSubview(backgroundView)
            addSubview(permissionLimitedView)
            backgroundView.snp.makeConstraints { maker in
                maker.edges.equalToSuperview()
            }
            permissionLimitedView.snp.makeConstraints { maker in
                maker.top.left.right.equalToSuperview()
                maker.height.equalTo(limitedViewHeight)
            }
        case .preview:
            break
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

// MARK: - PickerOptionsConfigurable
extension PickerToolBar: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        backgroundView.contentView.backgroundColor = options.theme[color: .toolBar].withAlphaComponent(0.7)
        switch style {
        case .picker:
            isHidden = isLimited ? false : options.selectionTapAction.hideToolBar && options.selectLimit == 1
            leftButton.setTitle(options.theme[string: .preview], for: .normal)
        case .preview:
            backgroundColor = options.theme[color: .toolBar].withAlphaComponent(0.95)
            leftButton.setTitle(options.theme[string: .edit], for: .normal)
        }
        leftButton.setTitleColor(options.theme[color: .text], for: .normal)
        leftButton.setTitleColor(options.theme[color: .text].withAlphaComponent(0.3), for: .disabled)
        doneButton.backgroundColor = options.theme[color: .primary]
        let normal = UIColor.create(style: options.theme.style,
                                    light: .white,
                                    dark: options.theme[color: .text])
        let disabled = UIColor.create(style: options.theme.style,
                                      light: UIColor.white.withAlphaComponent(0.7),
                                      dark: options.theme[color: .text].withAlphaComponent(0.3))
        doneButton.setTitleColor(normal, for: .normal)
        doneButton.setTitleColor(disabled, for: .disabled)
        originalButton.setImage(options.theme[icon: .checkOn], for: .selected)
        originalButton.setImage(options.theme[icon: .checkOff], for: .normal)
        originalButton.setTitleColor(options.theme[color: .text], for: .selected)
        originalButton.setTitleColor(options.theme[color: .text], for: .normal)
        originalButton.tintColor = options.theme[color: .primary]
        originalButton.isHidden = !options.allowUseOriginalImage
        updateChildrenConfigurable(options: options)
        
        originalButton.setTitle(options.theme[string: .pickerOriginalImage], for: .normal)
        doneButton.setTitle(options.theme[string: .done], for: .normal)
        
        switch style {
        case .picker:
            options.theme.buttonConfiguration[.preview]?.configuration(leftButton)
            options.theme.buttonConfiguration[.originalImage]?.configuration(originalButton)
            options.theme.buttonConfiguration[.done]?.configuration(doneButton)
        case .preview:
            options.theme.buttonConfiguration[.edit]?.configuration(leftButton)
            options.theme.buttonConfiguration[.originalImage]?.configuration(originalButton)
            options.theme.buttonConfiguration[.done]?.configuration(doneButton)
        }
    }
}

// MARK: - Function
extension PickerToolBar {
    
    func setEnable(_ enable: Bool) {
        leftButton.isEnabled = enable
        doneButton.isEnabled = enable
        doneButton.alpha = enable ? 1.0 : 0.5
    }
    
    func showLimitedView() {
        isLimited = true
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
