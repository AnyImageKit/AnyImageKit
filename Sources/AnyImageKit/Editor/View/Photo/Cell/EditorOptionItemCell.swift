//
//  EditorOptionItemCell.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/22.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorOptionItemCell: UICollectionViewCell, SKLoadViewProtocol {
    
    let selectEvent = Delegate<Model, Void>()
    
    private var model: Model?
    
    private(set) lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.tintColor = .white
        button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
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
            maker.width.height.equalTo(44)
        }
    }
}

// MARK: - Actions
extension EditorOptionItemCell {
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        guard let model else { return }
        selectEvent.call(model)
    }
}

// MARK: - ConfigurableView
extension EditorOptionItemCell: SKConfigurableView {
    
    final class Model: Equatable {
        let id = UUID().uuidString
        let image: UIImage?
        var isSelected: Bool
        let tintColor: UIColor
        
        init(image: UIImage?, isSelected: Bool, tintColor: UIColor) {
            self.image = image
            self.isSelected = isSelected
            self.tintColor = tintColor
        }
        
        static func == (lhs: Model, rhs: Model) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    func config(_ model: Model) {
        self.model = model
        button.setImage(model.image, for: .normal)
        button.isSelected = model.isSelected
        button.imageView?.tintColor = model.isSelected ? model.tintColor : .white
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: 44, height: 44)
    }
}
