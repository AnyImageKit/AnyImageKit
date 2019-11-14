//
//  PickerArrowButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PickerArrowButton: UIControl {
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.text = BundleHelper.pickerLocalizedString(key: "Photo")
        view.textColor = PickerManager.shared.config.theme.textColor
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        let style = PickerManager.shared.config.theme.style
        view.image = BundleHelper.image(named: "AlbumArrow", style: style)
        return view
    }()
    
    private lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: getStyle())
        let view = UIVisualEffectView(effect: effect)
        let color = ColorHelper.createByStyle(light: UIColor.black.withAlphaComponent(0.1), dark: UIColor.white.withAlphaComponent(0.9))
        view.backgroundColor = color
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        return view
    }()
    
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
        if #available(iOS 13, *) {
            guard PickerManager.shared.config.theme.style == .auto else { return }
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
            
            effectView.effect = UIBlurEffect(style: getStyle())
            let color = ColorHelper.createByStyle(light: UIColor.black.withAlphaComponent(0.1), dark: UIColor.white.withAlphaComponent(0.9))
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
    
    private func getStyle() -> UIBlurEffect.Style {
        let style: UIBlurEffect.Style
        switch PickerManager.shared.config.theme.style {
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
