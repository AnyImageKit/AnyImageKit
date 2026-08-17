//
//  PickerPreviewNavigationBar.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class PickerPreviewNavigationBar: UIView {
    
    let backEvent = Delegate<Void, Void>()
    let selectEvent = Delegate<Void, Void>()
    let editEvent = Delegate<Void, Void>()
    let useOriginalImageEvent = Delegate<Bool, Void>()
    
    private lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        view.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return view
    }()
    private lazy var selectButton: NumberCircleButton = {
        let view = NumberCircleButton(frame: .zero, style: .large)
        view.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var lgBackButton: UIButton = {
        guard #available(iOS 26.0, *) else {
            return UIButton()
        }
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.glass()
        config.preferredSymbolConfigurationForImage = .init(pointSize: 18, weight: .medium)
        view.configuration = config
        view.addAction(UIAction(handler: { [weak self] _ in
            self?.backEvent.call()
        }), for: .touchUpInside)
        return view
    }()
    private lazy var lgSelectButton: NumberCircleLGButton = {
        guard #available(iOS 26.0, *) else {
            return NumberCircleLGButton()
        }
        let view = NumberCircleLGButton(type: .system)
        var config = UIButton.Configuration.glass()
        config.preferredSymbolConfigurationForImage = .init(pointSize: 18, weight: .medium)
        view.configuration = config
        view.addAction(UIAction(handler: { [weak self] _ in
            self?.selectEvent.call()
        }), for: .touchUpInside)
        return view
    }()
    private lazy var lgEditButton: UIButton = {
        guard #available(iOS 26.0, *) else {
            return UIButton()
        }
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.glass()
        config.image = UIImage(systemName: "slider.horizontal.3")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 18, weight: .medium)
        view.configuration = config
        view.addAction(UIAction(handler: { [weak self] _ in
            self?.editEvent.call()
        }), for: .touchUpInside)
        return view
    }()
    private lazy var lgMoreButton: UIButton = {
        guard #available(iOS 26.0, *) else {
            return UIButton()
        }
        let view = UIButton(type: .system)
        view.showsMenuAsPrimaryAction = true
        var config = UIButton.Configuration.glass()
        config.image = UIImage(systemName: "ellipsis")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 18, weight: .medium)
        view.configuration = config
        return view
    }()
    
    private var didSetupView = false
    var useOriginalImage = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Action
extension PickerPreviewNavigationBar {
    
    @objc private func backButtonTapped() {
        backEvent.call()
    }
    
    @objc private func selectButtonTapped() {
        selectEvent.call()
    }
}

// MARK: - PickerOptionsConfigurable
extension PickerPreviewNavigationBar {
    
    func setNum(_ num: Int, isSelected: Bool, animated: Bool) {
        if lgSelectButton.superview != nil {
            lgSelectButton.setNum(num, isSelected: isSelected, animated: animated)
        } else {
            selectButton.setNum(num, isSelected: isSelected, animated: animated)
        }
    }
    
}

// MARK: - PickerOptionsConfigurable
extension PickerPreviewNavigationBar: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        if !didSetupView {
            didSetupView = true
            setupView(options: options)
        }
        
        if #available(iOS 26.0, *), !options.designRequiresCompatibility {
            lgBackButton.configuration?.image = options.theme[icon: .returnButtonLiquidGlass]
            lgBackButton.accessibilityLabel = options.theme[string: .back]
        } else {
            backgroundColor = options.theme[color: .toolBar].withAlphaComponent(0.95)
            backButton.setImage(options.theme[icon: .returnButton], for: .normal)
            backButton.accessibilityLabel = options.theme[string: .back]
        }
        
        updateChildrenConfigurable(options: options)
        options.theme.buttonConfiguration[.backInPreview]?.configuration(backButton)
    }
}

// MARK: - UI
extension PickerPreviewNavigationBar {
    
    private func setupView(options: PickerOptionsInfo) {
        let contentView = UILayoutGuide()
        addLayoutGuide(contentView)
        contentView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(44)
        }
        
        if #available(iOS 26.0, *), !options.designRequiresCompatibility {
            addSubview(lgBackButton)
            addSubview(lgSelectButton)
            
            lgBackButton.snp.makeConstraints { maker in
                maker.left.equalToSuperview().offset(16)
                maker.centerY.equalTo(contentView)
                maker.width.height.equalTo(44)
            }
            lgSelectButton.snp.makeConstraints { maker in
                maker.right.equalToSuperview().offset(-16)
                maker.centerY.equalTo(contentView)
                maker.width.height.equalTo(44)
            }
        } else {
            addSubview(backButton)
            addSubview(selectButton)
            backButton.snp.makeConstraints { maker in
                maker.left.equalToSuperview().offset(8)
                maker.centerY.equalTo(contentView)
                maker.width.height.equalTo(44)
            }
            selectButton.snp.makeConstraints { maker in
                maker.right.equalToSuperview().offset(-4)
                maker.centerY.equalTo(contentView)
                maker.width.height.equalTo(45)
            }
        }
    }
}
