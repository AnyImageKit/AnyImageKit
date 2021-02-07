//
//  PickerArrowButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/18.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PickerArrowButton: UIControl {
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = BundleHelper.localizedString(key: "PHOTO", module: .core)
        view.textColor = options.theme.textColor
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        let style = options.theme.style
        view.image = BundleHelper.image(named: "AlbumArrow", style: style, module: .picker)
        return view
    }()
    
    private lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: loadBlurEffectStyle())
        let view = UIVisualEffectView(effect: effect)
        let color = UIColor.create(style: options.theme.style,
                                   light: UIColor.black.withAlphaComponent(0.1),
                                   dark: UIColor.white.withAlphaComponent(0.9))
        view.backgroundColor = color
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        return view
    }()
    
    let options: PickerOptionsInfo
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(self.isSelected ? Double.pi : 0))
                self.layoutIfNeeded()
            }
        }
    }
    
    init(frame: CGRect, options: PickerOptionsInfo) {
        self.options = options
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
            guard options.theme.style == .auto else { return }
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
            
            effectView.effect = UIBlurEffect(style: loadBlurEffectStyle())
            let color = UIColor.create(style: options.theme.style,
                                       light: UIColor.black.withAlphaComponent(0.1),
                                       dark: UIColor.white.withAlphaComponent(0.9))
            effectView.backgroundColor = color
        }
    }
}

// MARK: - function
extension PickerArrowButton {
    
    func setTitle(_ title: String) {
        if isSelected {
            isSelected = false
        }
        UIView.animate(withDuration: 0.2) {
            self.label.text = title
            self.layoutIfNeeded()
        }
        accessibilityLabel = String(format: BundleHelper.localizedString(key: "A11Y_SWITCH_ALBUM_TIPS", module: .picker), title)
    }
}

// MARK: - Target
extension PickerArrowButton {
    
    @objc private func buttonTapped(_ sender: UIButton) {
        isSelected.toggle()
    }
}

// MARK: - Private function
extension PickerArrowButton {
    
    private func loadBlurEffectStyle() -> UIBlurEffect.Style {
        let style: UIBlurEffect.Style
        switch options.theme.style {
        case .auto:
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    style = .dark
                } else {
                    style = .light
                }
            } else {
                style = .light
            }
        case .light:
            style = .light
        case .dark:
            style = .dark
        }
        return style
    }
}
