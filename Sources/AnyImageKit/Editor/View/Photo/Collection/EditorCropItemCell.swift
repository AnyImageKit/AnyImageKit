//
//  EditorCropItemCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/7/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class EditorCropItemCell: UICollectionViewCell {
    
    private lazy var selectedBgView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor.color(hex: 0x434343)
        return view
    }()
    private lazy var titleLabel: UILabel = {
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

// MARK: - Config
extension EditorCropItemCell: ConfigurableView {
    
    struct Model {
        let title: String
        let isSelected: Bool
    }
    
    func config(_ model: Model) {
        titleLabel.text = model.title
        selectedBgView.isHidden = !model.isSelected
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        let labelWidth = NSAttributedString(string: model?.title ?? "").size(maxHeight: 24).width
        return CGSize(width: min(labelWidth, 20) + 20, height: 24)
    }
    
}

// MARK: - UI
extension EditorCropItemCell {
    
    private func setupView() {
        contentView.addSubview(selectedBgView)
        contentView.addSubview(titleLabel)
        
        selectedBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
