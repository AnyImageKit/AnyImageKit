//
//  EditorBrushItemCell.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/7.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorBrushItemCell: UICollectionViewCell, SKLoadViewProtocol {
    
    let selectEvent = Delegate<EditorBrushItemModel, Void>()
    
    private var model: Model?
    
    private(set) lazy var colorButton: UIButton = {
        let view = UIButton(type: .custom)
        view.clipsToBounds = true
        view.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
        return view
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
        addSubview(colorButton)
        colorButton.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(24)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorButton.backgroundColor = model?.color
        
        colorButton.layer.borderWidth = (model?.isSelected ?? false) ? 2 * 1.5 : 2
        colorButton.layer.borderColor = UIColor.white.cgColor
        colorButton.layer.cornerRadius = colorButton.bounds.width / 2
        
        let scale: CGFloat = (model?.isSelected ?? false) ? 1.25 : 1.0
        colorButton.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}

// MARK: - Actions
extension EditorBrushItemCell {
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        guard let model else { return }
        selectEvent.call(model)
    }
}

// MARK: - ConfigurableView
extension EditorBrushItemCell: SKConfigurableView {
    
    typealias Model = EditorBrushItemModel
    
    func config(_ model: Model) {
        self.model = model
        layoutIfNeeded()
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: 34, height: 34)
    }
}
