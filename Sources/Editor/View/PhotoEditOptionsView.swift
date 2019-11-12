//
//  PhotoEditOptionsView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol PhotoEditOptionsViewDelegate: class {
    
    func editOptionsView(_ editOptionsView: PhotoEditOptionsView, optionDidChange option: ImageEditorController.PhotoEditOption?)
    
}

final class PhotoEditOptionsView: UIView {
    
    weak var delegate: PhotoEditOptionsViewDelegate?
    
    private(set) var currentOption: ImageEditorController.PhotoEditOption?
    
    private let options: [ImageEditorController.PhotoEditOption]
    private var buttons: [UIButton] = []
    private let spacing: CGFloat = 25
    
    init(frame: CGRect, options: [ImageEditorController.PhotoEditOption]) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        for (idx, option) in options.enumerated() {
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
            btn.imageView?.tintColor = isSelected ? EditorManager.shared.photoConfig.tintColor : .white
        }
    }
}

// MARK: - Public function
extension PhotoEditOptionsView {
    
    func unSelectButtons() {
        self.currentOption = nil
        for button in buttons {
            button.isSelected = false
            button.imageView?.tintColor = .white
        }
    }
}

// MARK: - ResponseTouch
extension PhotoEditOptionsView: ResponseTouch {
    
    @discardableResult
    func responseTouch(_ point: CGPoint) -> Bool {
        for (idx, button) in buttons.enumerated() {
            let frame = button.frame.bigger(.init(top: spacing/4, left: spacing/2, bottom: spacing*0.8, right: spacing/2))
            if frame.contains(point) { // inside
                if let current = currentOption, options[idx] == current {
                    unSelectButtons()
                } else {
                    self.currentOption = options[idx]
                    selectButton(button)
                }
                delegate?.editOptionsView(self, optionDidChange: self.currentOption)
                return true
            }
        }
        return false
    }
}
