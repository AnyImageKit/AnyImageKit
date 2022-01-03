//
//  TitleMapCell.swift
//  Example
//
//  Created by 刘栋 on 2020/11/4.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class TitleMapCell: UITableViewCell {
    
    private lazy var tileMapView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleToFill
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
        contentView.addSubview(tileMapView)
        tileMapView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(8)
        }
    }
}
