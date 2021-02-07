//
//  EditorEditOptionsView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorEditOptionsViewDelegate: AnyObject {
    
    func editOptionsView(_ editOptionsView: EditorEditOptionsView, optionDidChange option: EditorPhotoToolOption?)
}

final class EditorEditOptionsView: UIView {
    
    weak var delegate: EditorEditOptionsViewDelegate?
    
    private(set) var currentOption: EditorPhotoToolOption?
    
    private let options: EditorPhotoOptionsInfo
    private var buttons: [UIButton] = []
    private let spacing: CGFloat = 25
    
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
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(35)
        }
        buttons.forEach {
            $0.snp.makeConstraints { maker in
                maker.width.equalTo(25)
                maker.height.equalTo(stackView.snp.height)
            }
        }
    }
    
    private func createButton(tag: Int, option: EditorPhotoToolOption) -> UIButton {
        let button = BigButton(moreInsets: UIEdgeInsets(top: spacing/4, left: spacing/2, bottom: spacing*0.8, right: spacing/2))
        let image = BundleHelper.image(named: option.imageName, module: .editor)?.withRenderingMode(.alwaysTemplate)
        button.tag = tag
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .white
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.accessibilityLabel = BundleHelper.localizedString(key: option.description, module: .editor)
        return button
    }
    
    private func selectButton(_ button: UIButton) {
        currentOption = options.toolOptions[button.tag]
        for btn in buttons {
            let isSelected = btn == button
            btn.isSelected = isSelected
            btn.imageView?.tintColor = isSelected ? options.tintColor : .white
        }
    }
}

// MARK: - Target
extension EditorEditOptionsView {
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if let current = currentOption, options.toolOptions[sender.tag] == current {
            unselectButtons()
        } else {
            selectButton(sender)
        }
        delegate?.editOptionsView(self, optionDidChange: currentOption)
    }
}

// MARK: - Public function
extension EditorEditOptionsView {
    
    public func selectFirstItemIfNeeded() {
        if self.currentOption == nil && self.options.toolOptions.count == 1 && self.options.toolOptions.first! != .text {
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

// MARK: - Event
extension EditorEditOptionsView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || !isUserInteractionEnabled || alpha < 0.01 {
            return nil
        }
        for subView in buttons {
            if let hitView = subView.hitTest(subView.convert(point, from: self), with: event) {
                return hitView
            }
        }
        return nil
    }
}
