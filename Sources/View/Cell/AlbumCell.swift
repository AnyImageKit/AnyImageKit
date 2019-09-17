//
//  AlbumCell.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class AlbumCell: UITableViewCell {
    
    private var album: Album?
    
    private(set) lazy var posterImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.textColor = UIColor.black
        return view
    }()
    
    private(set) lazy var subTitleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.textColor = UIColor.gray
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
        accessoryType = .disclosureIndicator
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        posterImageView.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 70, height: 70))
            maker.left.equalTo(contentView.snp.left)
            maker.centerY.equalTo(contentView.snp.centerY)
        }
        titleLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.left.equalTo(posterImageView.snp.right).offset(8)
        }
        subTitleLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.left.equalTo(titleLabel.snp.right).offset(8)
        }
    }
}

extension AlbumCell {
    
    func set(content album: Album) {
        self.album = album
        titleLabel.text = album.name
        subTitleLabel.text = "(\(album.count))"
    }
}
