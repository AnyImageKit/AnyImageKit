//
//  EditorBrushItemColorWellCell.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/7.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import UIKit

@available(iOS 14, *)
final class EditorBrushItemColorWellCell: UICollectionViewCell, SKLoadViewProtocol {
    
    let selectEvent = Delegate<EditorBrushItemModel, Void>()
    let updateEvent = Delegate<EditorBrushItemModel, Void>()
    
    private var model: Model?
    
    private lazy var colorWellView: ColorWell = {
        let colorWell = ColorWell(itemSize: 24, borderWidth: 2)
        colorWell.backgroundColor = .clear
        colorWell.supportsAlpha = false
        colorWell.addTarget(self, action: #selector(colorWellTapped(_:)), for: .touchUpInside)
        colorWell.addTarget(self, action: #selector(colorWellValueChanged(_:)), for: .valueChanged)
        return colorWell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(colorWellView)
        colorWellView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(24)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let scale: CGFloat = (model?.isSelected ?? false) ? 1.25 : 1.0
        colorWellView.transform = CGAffineTransform(scaleX: scale, y: scale)
        colorWellView.selectedColor = model?.color
    }
}

// MARK: - Actions
@available(iOS 14, *)
extension EditorBrushItemColorWellCell {
    
    @objc private func colorWellTapped(_ sender: ColorWell) {
        guard let model else { return }
        selectEvent.call(model)
    }
    
    @objc private func colorWellValueChanged(_ sender: ColorWell) {
        guard let model else { return }
        model.color = sender.selectedColor ?? .white
        updateEvent.call(model)
    }
}

// MARK: - ConfigurableView
@available(iOS 14, *)
extension EditorBrushItemColorWellCell: SKConfigurableView {
    
    typealias Model = EditorBrushItemModel
    
    func config(_ model: Model) {
        self.model = model
        layoutIfNeeded()
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: 34, height: 34)
    }
}
