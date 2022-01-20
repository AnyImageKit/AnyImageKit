//
//  PhotoLibraryCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class PhotoLibraryCell: UITableViewCell {
    
    private lazy var coverView: UIImageView = makeCoverView()
    private lazy var titleLabel: UILabel = makeLabel()
    private lazy var subTitleLabel: UILabel = makeLabel()
    private lazy var separatorLine: UIView = makeSeparatorLine()
    
    private var task: Task<Void, Error>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
    }
}

// MARK: - UI
extension PhotoLibraryCell {
    
    private func setupView() {
        contentView.addSubview(coverView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        addSubview(separatorLine)
        coverView.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.width.equalTo(coverView.snp.height)
        }
        titleLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.left.equalTo(coverView.snp.right).offset(16)
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
    
    private func makeCoverView() -> UIImageView {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }
    
    private func makeLabel() -> UILabel {
        let view = UILabel(frame: .zero)
        view.font = UIFont.preferredFont(forTextStyle: .body)
        return view
    }
    
    private func makeSeparatorLine() -> UIView {
        let view = UIView(frame: .zero)
        return view
    }
}

// MARK: - Theme
extension PhotoLibraryCell {
    
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

// MARK: - Content
extension PhotoLibraryCell {
    
    func setContent(_ photoLibrary: PhotoLibraryAssetCollection, manager: PickerManager) {
        task?.cancel()
        task = Task {
            updateTheme(manager.options.theme)
            titleLabel.text = photoLibrary.localizedTitle
            subTitleLabel.text = "(\(photoLibrary.assetCount))"
            let targetSize = coverView.frame.size.displaySize
            for try await cover in photoLibrary.loadCover(targetSize: targetSize) {
                coverView.image = cover
            }
        }
    }
}
