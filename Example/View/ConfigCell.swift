//
//  ConfigCell.swift
//  Example
//
//  Created by 刘栋 on 2020/1/16.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class ConfigCell: UITableViewCell {
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        view.adjustsFontSizeToFitWidth = true
        if #available(iOS 13.0, *) {
            view.textColor = UIColor.label
        } else {
            view.textColor = UIColor.black
        }
        view.textAlignment = .left
        return view
    }()
    
    private(set) lazy var tagsButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        view.setTitleColor(UIColor.systemBlue, for: .normal)
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.tertiarySystemGroupedBackground
        } else {
            view.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        }
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2
        view.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private(set) lazy var contentLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.numberOfLines = 2
        view.adjustsFontSizeToFitWidth = true
        if #available(iOS 13.0, *) {
            view.textColor = UIColor.secondaryLabel
        } else {
            view.textColor = UIColor.gray
        }
        view.textAlignment = .right
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let layoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(layoutGuide)
        contentView.addSubview(titleLabel)
        contentView.addSubview(tagsButton)
        contentView.addSubview(contentLabel)
        layoutGuide.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(16)
        }
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(layoutGuide.snp.top)
            maker.left.equalTo(layoutGuide.snp.left).offset(4)
            maker.right.lessThanOrEqualTo(layoutGuide.snp.right)
        }
        tagsButton.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(4)
            maker.left.equalTo(layoutGuide.snp.left)
            maker.right.lessThanOrEqualTo(layoutGuide.snp.right)
            maker.bottom.equalTo(layoutGuide.snp.bottom)
        }
        contentLabel.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(layoutGuide.snp.right).offset(8)
            maker.right.equalToSuperview().offset(-20)
        }
    }
    
    public func setupData(_ rowType: RowTypeRule) {
        titleLabel.text = Bundle.main.localizedString(forKey: rowType.title, value: nil, table: nil)
        tagsButton.setTitle(rowType.options, for: .normal)
        contentLabel.text = rowType.defaultValue
    }
}
