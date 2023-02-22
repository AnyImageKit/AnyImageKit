//
//  EditorMosaicItemCell.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/8.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorMosaicItemCell: UICollectionViewCell, SKLoadViewProtocol {
    
    let selectEvent = Delegate<Model, Void>()
    
    private var model: Model?
    
    private(set) lazy var button: UIButton = {
        let inset: CGFloat = 5
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.clipsToBounds = true
        button.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        button.imageView?.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(mosaicButtonTapped(_:)), for: .touchUpInside)
        return button
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
        addSubview(button)
        button.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(34)
        }
    }
}

// MARK: - Actions
extension EditorMosaicItemCell {
    
    @objc private func mosaicButtonTapped(_ sender: UIButton) {
        guard let model else { return }
        selectEvent.call(model)
    }
}

// MARK: - ConfigurableView
extension EditorMosaicItemCell: SKConfigurableView {
    
    final class Model: Equatable {
        let id = UUID().uuidString
        var isSelected: Bool
        let image: UIImage?
        let isDefault: Bool
        let tintColor: UIColor
        
        init(isSelected: Bool, image: UIImage?, isDefault: Bool, tintColor: UIColor) {
            self.isSelected = isSelected
            self.image = image
            self.isDefault = isDefault
            self.tintColor = tintColor
        }
        
        static func == (lhs: Model, rhs: Model) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    func config(_ model: Model) {
        self.model = model
        
        button.setImage(model.image, for: .normal)
        if model.isDefault {
            button.tintColor = model.isSelected ? model.tintColor : .white
            button.imageView?.layer.borderWidth = 0
        } else {
            button.tintColor = .white
            button.imageView?.layer.borderWidth = model.isSelected ? 2 : 0
        }
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: 34, height: 34)
    }
}
