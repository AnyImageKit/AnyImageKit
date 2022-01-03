//
//  EditorMosaicToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/26.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol EditorMosaicToolViewDelegate: AnyObject {
    
    func mosaicToolView(_ mosaicToolView: EditorMosaicToolView, mosaicDidChange idx: Int)
    
    func mosaicToolViewUndoButtonTapped(_ mosaicToolView: EditorMosaicToolView)
}

final class EditorMosaicToolView: UIView {
    
    weak var delegate: EditorMosaicToolViewDelegate?
    
    private(set) var currentIdx: Int = 0
    
    private(set) lazy var undoButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isEnabled = false
        view.setImage(options.theme[icon: .photoToolUndo], for: .normal)
        view.accessibilityLabel = options.theme[string: .undo]
        view.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private let options: EditorPhotoOptionsInfo
    private var mosaicButtons: [UIButton] = []
    private let spacing: CGFloat = 40
    private let itemWidth: CGFloat = 22
    private let buttonWidth: CGFloat = 34
    
    init(frame: CGRect, options: EditorPhotoOptionsInfo) {
        self.options = options
        self.currentIdx = options.defaultMosaicIndex
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(undoButton)
        undoButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-8)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(buttonWidth)
        }
        
        setupMosaicView()
        updateState()
        
        options.theme.buttonConfiguration[.undo]?.configuration(undoButton)
    }
    
    private func setupMosaicView() {
        for (idx, option) in options.mosaicOptions.enumerated() {
            mosaicButtons.append(createMosaicButton(option, idx: idx))
        }
        
        let stackView = UIStackView(arrangedSubviews: mosaicButtons)
        stackView.isHidden = options.mosaicOptions.count <= 1
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        let width = itemWidth * CGFloat(mosaicButtons.count) + spacing * CGFloat(mosaicButtons.count - 1)
        let offset = (UIScreen.main.bounds.width - width - 20 * 2 - 20) / 2
        stackView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(offset)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(buttonWidth)
        }
        
        for button in mosaicButtons {
            button.snp.makeConstraints { maker in
                maker.width.height.equalTo(buttonWidth)
            }
        }
    }
    
    private func createMosaicButton(_ option: EditorMosaicOption, idx: Int) -> UIButton {
        let image: UIImage?
        switch option {
        case .default:
            image = options.theme[icon: .photoToolMosaicDefault]?.withRenderingMode(.alwaysTemplate)
        case .custom(let customMosaicIcon, let customMosaic):
            image = customMosaicIcon ?? customMosaic
        }
        let inset = (buttonWidth - itemWidth) / 2
        let button = UIButton(type: .custom)
        button.tag = idx
        button.tintColor = .white
        button.clipsToBounds = true
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        button.imageView?.layer.cornerRadius = option == .default ? 0 : 2
        button.imageView?.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(mosaicButtonTapped(_:)), for: .touchUpInside)
        options.theme.buttonConfiguration[.mosaic(option)]?.configuration(button)
        return button
    }
}

// MARK: - Public function
extension EditorMosaicToolView {
    
    func setMosaicIdx(_ idx: Int) {
        guard idx < mosaicButtons.count else { return }
        mosaicButtonTapped(mosaicButtons[idx])
    }
}

// MARK: - Private function
extension EditorMosaicToolView {
    
    private func updateState() {
        let option = options.mosaicOptions[currentIdx]
        switch option {
        case .default:
            for button in mosaicButtons {
                button.tintColor = options.theme[color: .primary]
                button.imageView?.layer.borderWidth = 0
            }
        default:
            for (idx, button) in mosaicButtons.enumerated() {
                button.tintColor = .white
                button.imageView?.layer.borderWidth = idx == currentIdx ? 2 : 0
            }
        }
    }
}

// MARK: - Target
extension EditorMosaicToolView {
    
    @objc private func mosaicButtonTapped(_ sender: UIButton) {
        if currentIdx != sender.tag {
            currentIdx = sender.tag
            layoutSubviews()
        }
        delegate?.mosaicToolView(self, mosaicDidChange: currentIdx)
        updateState()
    }
    
    @objc private func undoButtonTapped(_ sender: UIButton) {
        delegate?.mosaicToolViewUndoButtonTapped(self)
    }
}
