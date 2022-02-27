//
//  PhotoLibraryCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoLibraryCell: UITableViewCell {
    
    private lazy var coverView: UIImageView = makeCoverView()
    private lazy var titleLabel: UILabel = makeLabel()
    private lazy var subTitleLabel: UILabel = makeLabel()
    private lazy var separatorLine: UIView = makeSeparatorLine()
    private lazy var customSelectedbackgroundView: UIView = makeSelectedbackgroundView()
    
    private var optionsCancellable: AnyCancellable?
    private var task: Task<Void, Error>?
    
    @Published var options: PickerOptionsInfo = .init()
    
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
        selectedBackgroundView = customSelectedbackgroundView
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
        
        optionsCancellable = $options.sink { [weak self] newOptions in
            self?.update(options: newOptions)
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
    
    private func makeSelectedbackgroundView() -> UIView {
        let view = UIView(frame: .zero)
        return view
    }
}

// MARK: - Theme
extension PhotoLibraryCell: OptionsInfoUpdatableContent {
    
    func update(options: PickerOptionsInfo) {
        tintColor = options.theme[color: .primary]
        backgroundColor = options.theme[color: .background]
        customSelectedbackgroundView.backgroundColor = options.theme[color: .selectedCell]
        titleLabel.textColor = options.theme[color: .text]
        subTitleLabel.textColor = options.theme[color: .subText]
        separatorLine.backgroundColor = options.theme[color: .separatorLine]
        options.theme.labelConfiguration[.albumCellTitle]?.configuration(titleLabel)
        options.theme.labelConfiguration[.albumCellSubTitle]?.configuration(subTitleLabel)
    }
}

// MARK: - Content
extension PhotoLibraryCell {
    
    func setContent(_ photoLibrary: PhotoLibraryAssetCollection) {
        task?.cancel()
        task = Task {
            titleLabel.text = photoLibrary.localizedTitle
            subTitleLabel.text = "(\(photoLibrary.assetCount))"
            let targetSize = coverView.frame.size.displaySize
            for try await cover in photoLibrary.loadCover(targetSize: targetSize) {
                coverView.image = cover
            }
        }
    }
}
