//
//  AlbumCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class AlbumCell: UITableViewCell {
    
    private lazy var posterImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.preferredFont(forTextStyle: .body)
        return view
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.preferredFont(forTextStyle: .body)
        return view
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView(frame: .zero)
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
        // Subviews
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        addSubview(separatorLine)
        posterImageView.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.width.equalTo(posterImageView.snp.height)
        }
        titleLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.left.equalTo(posterImageView.snp.right).offset(16)
        }
        subTitleLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.left.equalTo(titleLabel.snp.right).offset(8)
        }
        separatorLine.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(0.5)
        }
    }
}

extension AlbumCell {
    
    private func updateTheme(_ theme: PickerTheme) {
        tintColor = theme[color: .primary]
        backgroundColor = theme[color: .background]
        let view = UIView(frame: .zero)
        view.backgroundColor = theme[color: .selectedCell]
        selectedBackgroundView = view
        titleLabel.textColor = theme[color: .text]
        subTitleLabel.textColor = theme[color: .subText]
        separatorLine.backgroundColor = theme[color: .separatorLine]
        
        theme.labelConfiguration[.albumCellTitle]?.configuration(titleLabel)
        theme.labelConfiguration[.albumCellSubTitle]?.configuration(subTitleLabel)
    }
}

extension AlbumCell {
    
    func setContent(_ album: Album, manager: PickerManager) {
        updateTheme(manager.options.theme)
        titleLabel.text = album.title
        subTitleLabel.text = "(\(album.count))"
        manager.requestPhoto(for: album) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.posterImageView.image = response.image
            case .failure(let error):
                _print(error)
            }
        }
    }
}
