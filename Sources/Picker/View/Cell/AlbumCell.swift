//
//  AlbumCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
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
        view.textColor = PickerManager.shared.config.theme.textColor
        return view
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.textColor = PickerManager.shared.config.theme.subTextColor
        return view
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = PickerManager.shared.config.theme.separatorLineColor
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
        tintColor = PickerManager.shared.config.theme.mainColor
        // Background Color
        backgroundColor = PickerManager.shared.config.theme.backgroundColor
        // Selected Background Color
        let view = UIView(frame: .zero)
        view.backgroundColor = PickerManager.shared.config.theme.selectedCellColor
        selectedBackgroundView = view
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
    
    func setContent(_ album: Album) {
        titleLabel.text = album.name
        subTitleLabel.text = "(\(album.count))"
        PickerManager.shared.requestPhoto(for: album) { [weak self] result in
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
