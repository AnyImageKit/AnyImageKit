//
//  EditorTextToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/2.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol EditorTextToolViewDelegate: AnyObject {
    
    func textToolView(_ toolView: EditorTextToolView, textButtonTapped isSelected: Bool)
    func textToolView(_ toolView: EditorTextToolView, colorDidChange idx: Int)
}

final class EditorTextToolView: UIView {
    
    weak var delegate: EditorTextToolViewDelegate?
    
    private var currentIdx: Int = 0
    
    private lazy var textButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isSelected = true
        view.setImage(options.theme[icon: .textNormalIcon], for: .normal)
        view.setImage(options.theme[icon: .photoToolText], for: .selected)
        view.addTarget(self, action: #selector(textButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private let options: EditorPhotoOptionsInfo
    private let colorOptions: [EditorTextColor]
    private var colorButtons: [ColorButton] = []
    private let spacing: CGFloat = 10
    private let itemWidth: CGFloat = 24
    private let buttonWidth: CGFloat = 34
    
    init(frame: CGRect, options: EditorPhotoOptionsInfo, idx: Int, isTextSelected: Bool) {
        self.options = options
        self.colorOptions = options.textColors
        self.currentIdx = idx
        super.init(frame: frame)
        setupView()
        self.textButton.isSelected = isTextSelected
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (idx, colorButton) in colorButtons.enumerated() {
            let scale: CGFloat = idx == currentIdx ? 1.25 : 1.0
            colorButton.colorView.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            let colorButtonRight = 56 + CGFloat(idx) * spacing + CGFloat(idx + 1) * itemWidth
            colorButton.isHidden = colorButtonRight > (bounds.width - 20)
        }
    }
    
    private func setupView() {
        addSubview(textButton)
        setupColorView()
        
        textButton.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(12)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(buttonWidth)
        }
        
        options.theme.buttonConfiguration[.textSwitch]?.configuration(textButton)
    }
    
    private func setupColorView() {
        for (idx, color) in colorOptions.enumerated() {
            colorButtons.append(createColorView(color, idx: idx))
        }
        let stackView = UIStackView(arrangedSubviews: colorButtons)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.left.equalTo(textButton.snp.right).offset(12)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(buttonWidth)
            if UIDevice.current.userInterfaceIdiom == .phone && colorOptions.count >= 5 {
                maker.right.equalToSuperview().offset(-20)
            }
        }
        
        if !(UIDevice.current.userInterfaceIdiom == .phone && colorOptions.count >= 5) {
            for button in colorButtons {
                button.snp.makeConstraints { maker in
                    maker.width.height.equalTo(buttonWidth)
                }
            }
        }
    }
    
    private func createColorView(_ color: EditorTextColor, idx: Int) -> ColorButton {
        let view = ColorButton(tag: idx, size: itemWidth, color: color.color, borderWidth: 2, borderColor: UIColor.white)
        view.isHidden = true
        view.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
        options.theme.buttonConfiguration[.textColor(color)]?.configuration(view.colorView)
        return view
    }
}

// MARK: - Target
extension EditorTextToolView {
    
    @objc private func textButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.textToolView(self, textButtonTapped: sender.isSelected)
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        if currentIdx != sender.tag {
            currentIdx = sender.tag
            layoutSubviews()
            delegate?.textToolView(self, colorDidChange: sender.tag)
        }
    }
}
