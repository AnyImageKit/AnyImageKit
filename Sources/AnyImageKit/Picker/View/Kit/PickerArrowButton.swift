//
//  PickerArrowButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/18.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class PickerArrowButton: UIControl {
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        view.text = BundleHelper.localizedString(key: "PHOTO", module: .picker)
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        return view
    }()
    
    private lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        return view
    }()
    
    private var preferredStyle: UserInterfaceStyle = .auto
    private var a11ySwitchAlbumTips = BundleHelper.localizedString(key: "A11Y_SWITCH_ALBUM_TIPS", module: .picker)
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(self.isSelected ? Double.pi : 0))
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
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
        effectView.snp.makeConstraints { maker in
            maker.height.equalTo(height)
            maker.edges.equalTo(snp.edges)
        }
        label.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(12)
        }
        imageView.snp.makeConstraints { maker in
            maker.left.equalTo(label.snp.right).offset(8)
            maker.right.equalToSuperview().offset(-6)
            maker.width.height.equalTo(20)
            maker.centerY.equalToSuperview()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            guard preferredStyle == .auto else { return }
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
            
            effectView.effect = UIBlurEffect(style: .init(uiStyle: preferredStyle,
                                                          traitCollection: traitCollection))
            let color = UIColor.create(style: preferredStyle,
                                       light: UIColor.black.withAlphaComponent(0.1),
                                       dark: UIColor.white.withAlphaComponent(0.9))
            effectView.backgroundColor = color
        }
    }
}

// MARK: - Function
extension PickerArrowButton {
    
    func setTitle(_ title: String) {
        if isSelected {
            isSelected = false
        }
        UIView.animate(withDuration: 0.2) {
            self.label.text = title
            self.layoutIfNeeded()
        }
        accessibilityLabel = String(format: a11ySwitchAlbumTips, title)
    }
}

// MARK: - Target
extension PickerArrowButton {
    
    @objc private func buttonTapped(_ sender: UIButton) {
        isSelected.toggle()
    }
}

// MARK: - PickerOptionsConfigurable
extension PickerArrowButton: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        preferredStyle = options.theme.style
        label.textColor = options.theme[color: .text]
        imageView.image = options.theme[icon: .albumArrow]
        effectView.effect = UIBlurEffect(style: .init(uiStyle: preferredStyle,
                                                      traitCollection: traitCollection))
        let effectViewColor = UIColor.create(style: preferredStyle,
                                             light: UIColor.black.withAlphaComponent(0.1),
                                             dark: UIColor.white.withAlphaComponent(0.9))
        effectView.backgroundColor = effectViewColor
        a11ySwitchAlbumTips = options.theme[string: .pickerA11ySwitchAlbumTips]
        
        options.theme.labelConfiguration[.albumTitle]?.configuration(label)
    }
}
