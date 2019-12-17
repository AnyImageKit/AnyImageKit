//
//  EditorEditOptionsView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorEditOptionsViewDelegate: class {
    
    func editOptionsView(_ editOptionsView: EditorEditOptionsView, optionDidChange option: ImageEditorController.PhotoEditOption?)
}

final class EditorEditOptionsView: UIView {
    
    weak var delegate: EditorEditOptionsViewDelegate?
    
    private(set) var currentOption: ImageEditorController.PhotoEditOption?
    
    private let config: ImageEditorController.PhotoConfig
    private var buttons: [UIButton] = []
    private let spacing: CGFloat = 25
    
    init(frame: CGRect, config: ImageEditorController.PhotoConfig) {
        self.config = config
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        for (idx, option) in config.editOptions.enumerated() {
            let button = createButton(with: option)
            button.tag = idx
            buttons.append(button)
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(25)
        }
        
        for button in buttons {
            button.snp.makeConstraints { (maker) in
                maker.width.height.equalTo(stackView.snp.height)
            }
        }
    }
    
    private func createButton(with option: ImageEditorController.PhotoEditOption) -> UIButton {
        let button = UIButton(type: .custom)
        let image = BundleHelper.image(named: option.imageName)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .white
        return button
    }
    
    private func selectButton(_ button: UIButton) {
        for btn in buttons {
            let isSelected = btn == button
            btn.isSelected = isSelected
            btn.imageView?.tintColor = isSelected ? config.tintColor : .white
        }
    }
}

// MARK: - Public function
extension EditorEditOptionsView {
    
    func unselectButtons() {
        self.currentOption = nil
        for button in buttons {
            button.isSelected = false
            button.imageView?.tintColor = .white
        }
    }
}

// MARK: - ResponseTouch
extension EditorEditOptionsView: ResponseTouch {
    
    @discardableResult
    func responseTouch(_ point: CGPoint) -> Bool {
        for (idx, button) in buttons.enumerated() {
            let frame = button.frame.bigger(.init(top: spacing/4, left: spacing/2, bottom: spacing*0.8, right: spacing/2))
            if frame.contains(point) { // inside
                if let current = currentOption, config.editOptions[idx] == current {
                    unselectButtons()
                } else {
                    self.currentOption = config.editOptions[idx]
                    selectButton(button)
                }
                delegate?.editOptionsView(self, optionDidChange: self.currentOption)
                return true
            }
        }
        return false
    }
}
