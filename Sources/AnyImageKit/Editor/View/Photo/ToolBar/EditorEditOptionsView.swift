//
//  EditorEditOptionsView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol EditorEditOptionsViewDelegate: AnyObject {
    
    @discardableResult
    func editOptionsView(_ editOptionsView: EditorEditOptionsView, optionWillChange option: EditorPhotoToolOption?) -> Bool
}

final class EditorEditOptionsView: UIView {
    
    weak var delegate: EditorEditOptionsViewDelegate?
    
    private(set) var currentOption: EditorPhotoToolOption?
    
    private let options: EditorPhotoOptionsInfo
    private var buttons: [UIButton] = []
    
    init(frame: CGRect, options: EditorPhotoOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        for (idx, option) in options.toolOptions.enumerated() {
            let button = createButton(tag: idx, option: option)
            buttons.append(button)
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalToSuperview().inset(12)
        }
        buttons.forEach {
            $0.snp.makeConstraints { maker in
                maker.width.height.equalTo(stackView.snp.height)
            }
            options.theme.buttonConfiguration[.photoOptions(options.toolOptions[$0.tag])]?.configuration($0)
        }
    }
    
    private func createButton(tag: Int, option: EditorPhotoToolOption) -> UIButton {
        let button = UIButton(type: .custom)
        let image = options.theme[icon: option.iconKey]?.withRenderingMode(.alwaysTemplate)
        button.tag = tag
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .white
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.accessibilityLabel = options.theme[string: option.stringKey]
        return button
    }
    
    private func selectButton(_ button: UIButton) {
        currentOption = options.toolOptions[button.tag]
        for btn in buttons {
            let isSelected = btn == button
            btn.isSelected = isSelected
            btn.imageView?.tintColor = isSelected ? options.theme[color: .primary] : .white
        }
    }
}

// MARK: - Target
extension EditorEditOptionsView {
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let nextOption: EditorPhotoToolOption?
        if let current = currentOption, options.toolOptions[sender.tag] == current {
            nextOption = nil
        } else {
            nextOption = options.toolOptions[sender.tag]
        }

        let result = delegate?.editOptionsView(self, optionWillChange: nextOption) ?? false
        guard result else { return }
        if nextOption == nil {
            unselectButtons()
        } else {
            selectButton(sender)
        }
    }
}

// MARK: - Public function
extension EditorEditOptionsView {
    
    public func selectFirstItemIfNeeded() {
        if currentOption == nil && options.toolOptions.count == 1 && options.toolOptions.first! != .text {
            buttonTapped(buttons.first!)
        }
    }
    
    func unselectButtons() {
        self.currentOption = nil
        for button in buttons {
            button.isSelected = false
            button.imageView?.tintColor = .white
        }
    }
}
