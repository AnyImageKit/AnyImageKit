//
//  EditorCropItemCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/7/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorCropItemCell: UICollectionViewCell, SKLoadViewProtocol {
    
    let selectEvent = Delegate<Model, Void>()
    
    private var model: Model?
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .custom)
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.backgroundColor = .clear
        view.addTarget(self, action: #selector(cropButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textColor = .white
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions
extension EditorCropItemCell {
    
    @objc private func cropButtonTapped(_ sender: UIButton) {
        guard let model else { return }
        selectEvent.call(model)
    }
}

// MARK: - Config
extension EditorCropItemCell: SKConfigurableView {
    
    final class Model: Equatable {
        let id = UUID().uuidString
        let title: String
        var isSelected: Bool
        
        init(title: String, isSelected: Bool) {
            self.title = title
            self.isSelected = isSelected
        }
        
        static func == (lhs: Model, rhs: Model) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    func config(_ model: Model) {
        self.model = model
        titleLabel.text = model.title
        button.backgroundColor = model.isSelected ? UIColor.color(hex: 0x434343) : .clear
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        let labelWidth = NSAttributedString(string: model?.title ?? "").size(maxHeight: 24).width
        return CGSize(width: max(ceil(labelWidth), 20) + 20, height: 24)
    }
    
}

// MARK: - UI
extension EditorCropItemCell {
    
    private func setupView() {
        contentView.addSubview(button)
        contentView.addSubview(titleLabel)
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
