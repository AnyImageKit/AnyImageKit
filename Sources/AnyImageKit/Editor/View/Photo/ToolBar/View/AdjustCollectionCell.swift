//
//  AdjustCollectionCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class AdjustCollectionCell: UICollectionViewCell {
    
    @Injected(\.photoOptions)
    private var photoOptions: EditorPhotoOptionsInfo
    
    private lazy var positiveColor = photoOptions.theme[color: .primary]
    private lazy var negativeColor = UIColor.white
    
    private lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.alpha = 0.4
        view.backgroundColor = UIColor.black
        view.layer.cornerRadius = 27
        view.layer.borderWidth = 2
        return view
    }()
    private lazy var presentView: AdjustBackgroundView = {
        let view = AdjustBackgroundView(positiveColor: positiveColor, negativeColor: negativeColor)
        view.backgroundColor = .clear
        return view
    }()
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private lazy var valueLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.isHidden = true
        view.font = .systemFont(ofSize: 14)
        view.textAlignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(bgView)
        contentView.addSubview(presentView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(valueLabel)
        
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(54)
        }
        presentView.snp.makeConstraints { make in
            make.edges.equalTo(bgView)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(25)
        }
        valueLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func hiddenLabel(_ flag: Bool) {
        iconImageView.isHidden = !flag
        valueLabel.isHidden = flag
    }
    
    func config(option: EditorAdjustTypeOption, value: CGFloat, hiddenLabel: Bool = true) {
        iconImageView.image = photoOptions.theme[icon: option.iconKey]
        iconImageView.isHidden = !hiddenLabel
        valueLabel.isHidden = hiddenLabel
        valueLabel.text = String(format: "%.0lf", value * 100)
        valueLabel.textColor = value > 0 ? positiveColor : negativeColor
        bgView.layer.borderColor = value > 0 ? positiveColor.cgColor : negativeColor.cgColor
        presentView.value = value
    }
}
