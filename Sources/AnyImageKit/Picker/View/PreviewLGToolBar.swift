//
//  PreviewLGToolBar.swift
//  AnyImageKit
//
//  Created by OpenAI Codex.
//

import UIKit

final class PreviewLGToolBar: UIView {
    
    private enum Layout {
        static let sideButtonWidth: CGFloat = 72
        static let sideButtonHeight: CGFloat = 48
        static let originalButtonWidth: CGFloat = 82
        static let originalButtonHeight: CGFloat = 48
        static let horizontalInset: CGFloat = 15
    }
    
    private var options: PickerOptionsInfo?
    private var originalSelected = false
    
    private(set) lazy var editButton: UIButton = {
        let view = UIButton(type: .system)
        return view
    }()
    
    private(set) lazy var originalButton: UIButton = {
        let view = UIButton(type: .system)
        return view
    }()
    
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .system)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setShowsEdit(_ showsEdit: Bool) {
        editButton.isHidden = !showsEdit
    }
    
    func setShowsOriginal(_ showsOriginal: Bool) {
        originalButton.isHidden = !showsOriginal
    }
    
    func setOriginalSelected(_ isSelected: Bool) {
        originalSelected = isSelected
        if let options {
            applyOriginalStyle(options: options)
        }
    }
    
    func setDoneEnable(_ enable: Bool) {
        doneButton.isEnabled = enable
    }
    
    private func setupView() {
        addSubview(editButton)
        addSubview(originalButton)
        addSubview(doneButton)
        
        editButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview()
            make.width.equalTo(Layout.sideButtonWidth)
            make.height.equalTo(Layout.sideButtonHeight)
        }
        originalButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(Layout.originalButtonWidth)
            make.height.equalTo(Layout.originalButtonHeight)
        }
        doneButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview()
            make.width.equalTo(Layout.sideButtonWidth)
            make.height.equalTo(Layout.sideButtonHeight)
        }
    }
}

extension PreviewLGToolBar: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        self.options = options
        applyEditStyle(options: options)
        applyOriginalStyle(options: options)
        applyDoneStyle(options: options)
    }
    
    private func applyEditStyle(options: PickerOptionsInfo) {
        applyGlassStyle(to: editButton,
                        title: options.theme[string: .edit],
                        foregroundColor: options.theme[color: .text],
                        font: .systemFont(ofSize: 18))
        editButton.setTitleColor(options.theme[color: .text].withAlphaComponent(0.3), for: .disabled)
        options.theme.applyGlassButtonConfiguration(.edit, to: editButton)
    }
    
    private func applyOriginalStyle(options: PickerOptionsInfo) {
        let foregroundColor = options.theme[color: .text]
        let image = originalSelected ? options.theme[icon: .checkOn] : options.theme[icon: .checkOff]
        applyGlassStyle(to: originalButton,
                        title: options.theme[string: .pickerOriginalImage],
                        foregroundColor: foregroundColor,
                        image: image,
                        font: .systemFont(ofSize: 16))
        // Reapplied on every original-image toggle. The theme closure must be idempotent.
        options.theme.applyGlassButtonConfiguration(.originalImage, to: originalButton)
        restoreOriginalCheckImage(image)
    }
    
    private func restoreOriginalCheckImage(_ image: UIImage?) {
        if #available(iOS 26.0, *) {
            var config = originalButton.configuration
            config?.image = image
            config?.imagePlacement = .leading
            config?.imagePadding = image == nil ? 0 : 6
            originalButton.configuration = config
        } else {
            originalButton.setImage(image, for: .normal)
        }
    }
    
    private func applyDoneStyle(options: PickerOptionsInfo) {
        applyGlassStyle(to: doneButton,
                        title: options.theme[string: .done],
                        foregroundColor: options.theme[color: .primary],
                        font: .systemFont(ofSize: 18, weight: .bold))
        doneButton.setTitleColor(options.theme[color: .primary].withAlphaComponent(0.3), for: .disabled)
        options.theme.applyGlassButtonConfiguration(.done, to: doneButton)
    }
    
    private func applyGlassStyle(to button: UIButton,
                                 title: String,
                                 foregroundColor: UIColor,
                                 image: UIImage? = nil,
                                 font: UIFont) {
        if #available(iOS 26.0, *) {
            var config = UIButton.Configuration.glass()
            config.title = title
            config.image = image
            config.imagePlacement = .leading
            config.imagePadding = image == nil ? 0 : 6
            config.background.backgroundColor = .clear
            config.baseForegroundColor = foregroundColor
            config.contentInsets = .zero
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }
            button.configuration = config
        } else {
            button.setTitle(title, for: .normal)
            button.setImage(image, for: .normal)
            button.setTitleColor(foregroundColor, for: .normal)
            button.tintColor = foregroundColor
            button.titleLabel?.font = font
        }
    }
}
