//
//  EditorTextToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/2.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorTextToolViewDelegate: class {
    
    func textToolView(_ toolView: EditorTextToolView, textButtonTapped isSelected: Bool)
    func textToolView(_ toolView: EditorTextToolView, colorDidChange idx: Int)
}

final class EditorTextToolView: UIView {
    
    weak var delegate: EditorTextToolViewDelegate?
    
    private(set) var currentIdx: Int = 0
    
    private lazy var textButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isSelected = true
        view.setImage(BundleHelper.image(named: "TextNormalIcon"), for: .normal)
        view.setImage(BundleHelper.image(named: "PhotoToolText"), for: .selected)
        view.addTarget(self, action: #selector(textButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private let colors: [ImageEditorController.PhotoTextColor]
    private var colorViews: [UIButton] = []
    private let spacing: CGFloat = 22
    
    
    init(frame: CGRect, config: ImageEditorController.PhotoConfig) {
        self.colors = config.textColors
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (idx, colorView) in colorViews.enumerated() {
            let scale: CGFloat = idx == currentIdx ? 1.25 : 1.0
            colorView.transform = CGAffineTransform(scaleX: scale, y: scale)
            colorView.layer.borderWidth = idx == currentIdx ? 3 : 2
        }
    }
    
    private func setupView() {
        addSubview(textButton)
        setupColorView()
        
        textButton.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(25)
        }
    }
    
    private func setupColorView() {
        for (idx, color) in colors.enumerated() {
            colorViews.append(createColorView(color.color, idx: idx))
        }
        let stackView = UIStackView(arrangedSubviews: colorViews)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.snp.makeConstraints { (maker) in
            maker.left.equalTo(textButton.snp.right).offset(25)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(22)
        }
        
        for colorView in colorViews {
            colorView.snp.makeConstraints { (maker) in
                maker.width.height.equalTo(stackView.snp.height)
            }
        }
    }
    
    private func createColorView(_ color: UIColor, idx: Int) -> UIButton {
        let view = UIButton(type: .custom)
        view.tag = idx
        view.backgroundColor = color
        view.clipsToBounds = true
        view.layer.cornerRadius = 11
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
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
