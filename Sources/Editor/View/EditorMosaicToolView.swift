//
//  EditorMosaicToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/26.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol EditorMosaicToolViewDelegate: class {
    
    func mosaicToolView(_ mosaicToolView: EditorMosaicToolView, mosaicDidChange idx: Int)
    
    func mosaicToolViewUndoButtonTapped(_ mosaicToolView: EditorMosaicToolView)
}

final class EditorMosaicToolView: UIView {
    
    weak var delegate: EditorMosaicToolViewDelegate?
    
    private(set) var currentIdx: Int = 0
    
    private(set) lazy var undoButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isEnabled = false
        view.setImage(BundleHelper.image(named: "PhotoToolUndo"), for: .normal)
        view.accessibilityLabel = BundleHelper.editorLocalizedString(key: "Undo")
        return view
    }()
    
    private let options: EditorPhotoOptionsInfo
    private var mosaicIcon: [UIImageView] = []
    private let spacing: CGFloat = 40
    
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
        undoButton.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(22)
        }
        setupMosaicView()
        updateState()
    }
    
    private func setupMosaicView() {
        for option in options.mosaicOptions {
            let image: UIImage?
            switch option {
            case .default:
                image = BundleHelper.image(named: "PhotoToolMosaicDefault")?.withRenderingMode(.alwaysTemplate)
            case .custom(let customMosaicIcon, let customMosaic):
                image = customMosaicIcon ?? customMosaic
            }
            let imageView = UIImageView(image: image)
            imageView.tintColor = .white
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = option == .default ? 0 : 2
            imageView.layer.borderColor = UIColor.white.cgColor
            mosaicIcon.append(imageView)
        }
        
        let stackView = UIStackView(arrangedSubviews: mosaicIcon)
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        let width = 20 * CGFloat(mosaicIcon.count) + spacing * CGFloat(mosaicIcon.count-1)
        let offset = (UIScreen.main.bounds.width - width - 20*2 - 20) / 2
        stackView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(offset)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(20)
        }
        
        for icon in mosaicIcon {
            icon.snp.makeConstraints { (maker) in
                maker.width.height.equalTo(stackView.snp.height)
            }
        }
    }
}

// MARK: - Private function
extension EditorMosaicToolView {
    
    private func updateState() {
        let option = options.mosaicOptions[currentIdx]
        switch option {
        case .default:
            for imageView in mosaicIcon {
                imageView.tintColor = options.tintColor
                imageView.layer.borderWidth = 0
            }
        default:
            for (idx, imageView) in mosaicIcon.enumerated() {
                imageView.tintColor = .white
                imageView.layer.borderWidth = idx == currentIdx ? 2 : 0
            }
        }
    }
}

// MARK: - ResponseTouch
extension EditorMosaicToolView: ResponseTouch {
    
    @discardableResult
    func responseTouch(_ point: CGPoint) -> Bool {
        // Mosaic view
        let mosaicPoint = point.subtraction(with: mosaicIcon.first!.superview!.frame.origin)
        for (idx, mosaicView) in mosaicIcon.enumerated() {
            let frame = mosaicView.frame.bigger(.init(top: spacing/4, left: spacing/2, bottom: spacing*0.8, right: spacing/2))
            if frame.contains(mosaicPoint) { // inside
                if currentIdx != idx {
                    currentIdx = idx
                    layoutSubviews()
                }
                delegate?.mosaicToolView(self, mosaicDidChange: idx)
                updateState()
                return true
            }
        }
        // Undo
        let undoFrame = undoButton.frame.bigger(.init(top: 10, left: 15, bottom: 30, right: 30))
        if undoFrame.contains(point) {
            delegate?.mosaicToolViewUndoButtonTapped(self)
            return true
        }
        return false
    }
}
