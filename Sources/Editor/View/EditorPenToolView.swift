//
//  EditorPenToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorPenToolViewDelegate: class {
    
    func penToolView(_ penToolView: EditorPenToolView, colorDidChange idx: Int)
    
    func penToolViewUndoButtonTapped(_ penToolView: EditorPenToolView)
}

final class EditorPenToolView: UIView {
    
    weak var delegate: EditorPenToolViewDelegate?
    
    private(set) var currentIdx: Int
    
    private(set) lazy var undoButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isEnabled = false
        view.setImage(BundleHelper.image(named: "PhotoToolUndo"), for: .normal)
        view.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = BundleHelper.editorLocalizedString(key: "Undo")
        return view
    }()
    
    private let colors: [UIColor]
    private var colorButtons: [UIButton] = []
    private let spacing: CGFloat = 22
    private let itemWidth: CGFloat = 22
    
    init(frame: CGRect, options: EditorPhotoOptionsInfo) {
        self.colors = options.penColors
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
            colorView.transform = CGAffineTransform(scaleX: scale, y: scale)
            colorView.layer.borderWidth = idx == currentIdx ? 3 : 2
            
            let colorViewRight = CGFloat(idx) * spacing + CGFloat(idx + 1) * itemWidth
            colorView.isHidden = colorViewRight > (bounds.width - itemWidth)
        }
    }
    
    private func setupView() {
        setupColorView()
        addSubview(undoButton)
        
        undoButton.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(itemWidth)
        }
    }
    
    private func setupColorView() {
        for (idx, color) in colors.enumerated() {
            colorButtons.append(createColorButton(color, idx: idx))
        }
        let stackView = UIStackView(arrangedSubviews: colorButtons)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.equalTo(itemWidth)
        }
        
        for colorView in colorButtons {
            colorView.snp.makeConstraints { (maker) in
                maker.width.height.equalTo(stackView.snp.height)
            }
        }
    }
    
    private func createColorButton(_ color: UIColor, idx: Int) -> UIButton {
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
extension EditorPenToolView {
    
    @objc private func undoButtonTapped(_ sender: UIButton) {
        delegate?.penToolViewUndoButtonTapped(self)
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        if currentIdx != sender.tag {
            currentIdx = sender.tag
            layoutSubviews()
        }
        delegate?.penToolView(self, colorDidChange: currentIdx)
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
