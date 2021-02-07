//
//  EditorPenToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorPenToolViewDelegate: AnyObject {
    
    func penToolView(_ penToolView: EditorPenToolView, colorDidChange color: UIColor)
    
    func penToolViewUndoButtonTapped(_ penToolView: EditorPenToolView)
}

final class EditorPenToolView: UIView {
    
    weak var delegate: EditorPenToolViewDelegate?
    
    private(set) var currentIdx: Int
    
    private(set) lazy var undoButton: UIButton = {
        let view = BigButton(moreInsets: UIEdgeInsets(top: spacing/4, left: spacing/2, bottom: spacing*0.8, right: spacing/2))
        view.isEnabled = false
        view.setImage(BundleHelper.image(named: "PhotoToolUndo", module: .editor), for: .normal)
        view.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = BundleHelper.localizedString(key: "UNDO", module: .core)
        return view
    }()
    
    private let colorOptions: [EditorPenColorOption]
    private var colorButtons: [UIControl] = []
    private let spacing: CGFloat = 20
    private let itemWidth: CGFloat = 24
    
    init(frame: CGRect, options: EditorPhotoOptionsInfo) {
        self.colorOptions = options.penColors
        self.currentIdx = options.defaultPenIndex
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
                button.colorView.layer.borderWidth = idx == currentIdx ? 3 : 2
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
        setupColorView()
        addSubview(undoButton)
        
        undoButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(itemWidth)
        }
    }
    
    private func setupColorView() {
        for (idx, option) in colorOptions.enumerated() {
            colorButtons.append(createColorButton(by: option, idx: idx))
        }
        let stackView = UIStackView(arrangedSubviews: colorButtons)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(itemWidth)
        }
        
        for colorView in colorButtons {
            colorView.snp.makeConstraints { maker in
                maker.width.height.equalTo(itemWidth)
            }
        }
    }
    
    private func createColorButton(by option: EditorPenColorOption, idx: Int) -> UIControl {
        switch option {
        case .custom(let color):
            let button = ColorButton(tag: idx, size: itemWidth, color: color, borderWidth: 2, borderColor: UIColor.white)
            button.isHidden = true
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            return button
        case .colorWell(let color):
            if #available(iOS 14.0, *) {
                let colorWell = ColorWell(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth))
                colorWell.backgroundColor = .clear
                colorWell.tag = idx
                colorWell.selectedColor = color
                colorWell.supportsAlpha = false
                colorWell.addTarget(self, action: #selector(colorWellTapped(_:)), for: .touchUpInside)
                colorWell.addTarget(self, action: #selector(colorWellValueChanged(_:)), for: .valueChanged)
                return colorWell
            } else {
                fatalError()
            }
        }
    }
}

// MARK: - Target
extension EditorPenToolView {
    
    @objc private func undoButtonTapped(_ sender: UIButton) {
        delegate?.penToolViewUndoButtonTapped(self)
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        if currentIdx != sender.tag {
            currentIdx = sender.tag
            layoutSubviews()
        }
        delegate?.penToolView(self, colorDidChange: colorOptions[currentIdx].color)
    }
    
    @available(iOS 14, *)
    @objc private func colorWellTapped(_ sender: ColorWell) {
        if currentIdx != sender.tag {
            currentIdx = sender.tag
            layoutSubviews()
        }
        delegate?.penToolView(self, colorDidChange: sender.selectedColor ?? .white)
    }
    
    @available(iOS 14, *)
    @objc private func colorWellValueChanged(_ sender: ColorWell) {
        delegate?.penToolView(self, colorDidChange: sender.selectedColor ?? .white)
    }
}

// MARK: - Event
extension EditorPenToolView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || !isUserInteractionEnabled || alpha < 0.01 {
            return nil
        }
        var subViews: [UIView] = colorButtons
        subViews.append(undoButton)
        for subView in subViews {
            if let hitView = subView.hitTest(subView.convert(point, from: self), with: event) {
                return hitView
            }
        }
        return nil
    }
}
