//
//  EditorMosaicToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/26.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
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
        let view = BigButton(moreInsets: UIEdgeInsets(top: spacing/4, left: spacing/2, bottom: spacing*0.8, right: spacing/2))
        view.isEnabled = false
        view.setImage(BundleHelper.image(named: "PhotoToolUndo", module: .editor), for: .normal)
        view.accessibilityLabel = BundleHelper.localizedString(key: "UNDO", module: .core)
        view.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private let options: EditorPhotoOptionsInfo
    private var mosaicButtons: [UIButton] = []
    private let spacing: CGFloat = 40
    private let itemWidth: CGFloat = 24
    
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
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(itemWidth)
        }
        setupMosaicView()
        updateState()
    }
    
    private func setupMosaicView() {
        for (idx, option) in options.mosaicOptions.enumerated() {
            mosaicButtons.append(createMosaicButton(option, idx: idx))
        }
        
        let stackView = UIStackView(arrangedSubviews: mosaicButtons)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        let width = itemWidth * CGFloat(mosaicButtons.count) + spacing * CGFloat(mosaicButtons.count - 1)
        let offset = (UIScreen.main.bounds.width - width - 20 * 2 - 20) / 2
        stackView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(offset)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(itemWidth)
        }
        
        for icon in mosaicButtons {
            icon.snp.makeConstraints { maker in
                maker.width.height.equalTo(itemWidth)
            }
        }
    }
    
    private func createMosaicButton(_ option: EditorMosaicOption, idx: Int) -> UIButton {
        let image: UIImage?
        switch option {
        case .default:
            image = BundleHelper.image(named: "PhotoToolMosaicDefault", module: .editor)?.withRenderingMode(.alwaysTemplate)
        case .custom(let customMosaicIcon, let customMosaic):
            image = customMosaicIcon ?? customMosaic
        }
        let button = BigButton(moreInsets: UIEdgeInsets(top: spacing/4, left: spacing/2, bottom: spacing*0.8, right: spacing/2))
        button.tag = idx
        button.tintColor = .white
        button.clipsToBounds = true
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.imageView?.layer.cornerRadius = option == .default ? 0 : 2
        button.imageView?.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(mosaicButtonTapped(_:)), for: .touchUpInside)
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
                button.tintColor = options.tintColor
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

// MARK: - Event
extension EditorMosaicToolView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || !isUserInteractionEnabled || alpha < 0.01 {
            return nil
        }
        var subViews: [UIView] = mosaicButtons
        subViews.append(undoButton)
        for subView in subViews {
            if let hitView = subView.hitTest(subView.convert(point, from: self), with: event) {
                return hitView
            }
        }
        return nil
    }
}
