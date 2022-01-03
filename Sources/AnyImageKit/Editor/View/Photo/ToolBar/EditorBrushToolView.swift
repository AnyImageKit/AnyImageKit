//
//  EditorBrushToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol EditorBrushToolViewDelegate: AnyObject {
    
    func brushToolView(_ brushToolView: EditorBrushToolView, colorDidChange color: UIColor)
    
    func brushToolViewUndoButtonTapped(_ brushToolView: EditorBrushToolView)
}

final class EditorBrushToolView: UIView {
    
    weak var delegate: EditorBrushToolViewDelegate?
    
    private(set) var currentIdx: Int
    
    private(set) lazy var undoButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isEnabled = false
        view.setImage(options.theme[icon: .photoToolUndo], for: .normal)
        view.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = options.theme[string: .undo]
        return view
    }()
    
    private let options: EditorPhotoOptionsInfo
    private let colorOptions: [EditorBrushColorOption]
    private var colorButtons: [UIControl] = []
    private let spacing: CGFloat = 10
    private let itemWidth: CGFloat = 24
    private let buttonWidth: CGFloat = 34
    
    init(frame: CGRect, options: EditorPhotoOptionsInfo) {
        self.colorOptions = options.brushColors
        self.currentIdx = options.defaultBrushIndex
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (idx, colorView) in colorButtons.enumerated() {
            let scale: CGFloat = idx == currentIdx ? 1.25 : 1.0
            if let button = colorView as? ColorButton {
                button.colorView.transform = CGAffineTransform(scaleX: scale, y: scale)
                button.isSelected = idx == currentIdx
            }
            if #available(iOS 14.0, *) {
                if let colorWell = colorView as? ColorWell {
                    colorWell.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            
            let colorViewRight = CGFloat(idx) * spacing + CGFloat(idx + 1) * itemWidth
            colorView.isHidden = colorViewRight > (bounds.width - itemWidth)
        }
    }
    
    private func setupView() {
        addSubview(undoButton)
        setupColorView()
        
        undoButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-8)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(buttonWidth)
        }
        
        options.theme.buttonConfiguration[.undo]?.configuration(undoButton)
    }
    
    private func setupColorView() {
        for (idx, option) in colorOptions.enumerated() {
            colorButtons.append(createColorButton(by: option, idx: idx))
        }
        let stackView = UIStackView(arrangedSubviews: colorButtons)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(12)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(buttonWidth)
            if UIDevice.current.userInterfaceIdiom == .phone && colorOptions.count >= 5 {
                maker.right.equalTo(undoButton.snp.left).offset(-20)
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
    
    private func createColorButton(by option: EditorBrushColorOption, idx: Int) -> UIControl {
        switch option {
        case .custom(let color):
            let button = ColorButton(tag: idx, size: itemWidth, color: color, borderWidth: 2, borderColor: UIColor.white)
            button.isHidden = true
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            options.theme.buttonConfiguration[.brush(option)]?.configuration(button.colorView)
            return button
        case .colorWell(let color):
            if #available(iOS 14.0, *) {
                let colorWell = ColorWell(itemSize: itemWidth, borderWidth: 2)
                colorWell.backgroundColor = .clear
                colorWell.tag = idx
                colorWell.selectedColor = color
                colorWell.supportsAlpha = false
                colorWell.addTarget(self, action: #selector(colorWellTapped(_:)), for: .touchUpInside)
                colorWell.addTarget(self, action: #selector(colorWellValueChanged(_:)), for: .valueChanged)
                return colorWell
            } else {
                let button = ColorButton(tag: idx, size: itemWidth, color: color, borderWidth: 2, borderColor: UIColor.white)
                button.isHidden = true
                button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
                options.theme.buttonConfiguration[.brush(option)]?.configuration(button.colorView)
                return button
            }
        }
    }
}

// MARK: - Target
extension EditorBrushToolView {
    
    @objc private func undoButtonTapped(_ sender: UIButton) {
        delegate?.brushToolViewUndoButtonTapped(self)
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        if currentIdx != sender.tag {
            currentIdx = sender.tag
            layoutSubviews()
        }
        delegate?.brushToolView(self, colorDidChange: colorOptions[currentIdx].color)
    }
    
    @available(iOS 14, *)
    @objc private func colorWellTapped(_ sender: ColorWell) {
        if currentIdx != sender.tag {
            currentIdx = sender.tag
            layoutSubviews()
        }
        delegate?.brushToolView(self, colorDidChange: sender.selectedColor ?? .white)
    }
    
    @available(iOS 14, *)
    @objc private func colorWellValueChanged(_ sender: ColorWell) {
        delegate?.brushToolView(self, colorDidChange: sender.selectedColor ?? .white)
    }
}
