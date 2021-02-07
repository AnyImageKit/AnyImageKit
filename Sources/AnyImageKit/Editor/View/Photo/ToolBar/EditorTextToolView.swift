//
//  EditorTextToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/2.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
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
        view.setImage(BundleHelper.image(named: "TextNormalIcon", module: .editor), for: .normal)
        view.setImage(BundleHelper.image(named: "PhotoToolText", module: .editor), for: .selected)
        view.addTarget(self, action: #selector(textButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private let colors: [EditorTextColor]
    private var colorButtons: [ColorButton] = []
    private let spacing: CGFloat = 20
    private let itemWidth: CGFloat = 24
    
    init(frame: CGRect, options: EditorPhotoOptionsInfo, idx: Int, isTextSelected: Bool) {
        self.colors = options.textColors
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
            colorButton.colorView.layer.borderWidth = idx == currentIdx ? 3 : 2
            
            let colorButtonRight = 25 + 20 + CGFloat(idx) * spacing + CGFloat(idx + 1) * itemWidth
            colorButton.isHidden = colorButtonRight > bounds.width
        }
    }
    
    private func setupView() {
        addSubview(textButton)
        setupColorView()
        
        textButton.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(25)
        }
    }
    
    private func setupColorView() {
        for (idx, color) in colors.enumerated() {
            colorButtons.append(createColorView(color.color, idx: idx))
        }
        let stackView = UIStackView(arrangedSubviews: colorButtons)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.left.equalTo(textButton.snp.right).offset(20)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(itemWidth)
        }
        
        for colorView in colorButtons {
            colorView.snp.makeConstraints { maker in
                maker.width.height.equalTo(itemWidth)
            }
        }
    }
    
    private func createColorView(_ color: UIColor, idx: Int) -> ColorButton {
        let view = ColorButton(tag: idx, size: itemWidth, color: color, borderWidth: 2, borderColor: UIColor.white)
        view.isHidden = true
        view.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
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
