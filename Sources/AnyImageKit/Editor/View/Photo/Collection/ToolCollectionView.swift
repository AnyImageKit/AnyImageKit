//
//  ToolCollectionView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/22.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class ToolCollectionView: UIView {

    enum LayoutStyle {
        case full
        case center(value: CGFloat, offset: CGFloat)
        case leading(value: CGFloat, offset: CGFloat)
    }
    
    var spacing: CGFloat = 10 {
        didSet {
            flowLayout.minimumLineSpacing = spacing
            flowLayout.minimumInteritemSpacing = spacing
        }
    }
    
    var size: CGFloat = 44 {
        didSet {
            flowLayout.itemSize = .init(width: size, height: size)
        }
    }
    
    let items: [UIView]
    
    private(set) lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.itemSize = .init(width: size, height: size)
        layout.scrollDirection = .horizontal
        return layout
    }()
    private(set) lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.registerCell(ToolCollectionCell.self)
        return view
    }()
    
    init(items: [UIView], size: CGFloat, spacing: CGFloat) {
        self.items = items
        self.size = size
        self.spacing = spacing
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate
extension ToolCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(2)
    }
}

// MARK: - UICollectionViewDataSource
extension ToolCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ToolCollectionCell.self, for: indexPath)
        cell.config(view: items[indexPath.row])
        return cell
    }
}

// MARK: - UI
extension ToolCollectionView {
    
    private func setupView() {
        addSubview(collectionView)
        layout(style: .full)
    }
    
    func layout(style: LayoutStyle, isRegular: Bool = false) {
        switch style {
        case .full:
            collectionView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .center(let value, let offset):
            collectionView.snp.remakeConstraints { make in
                if isRegular { // iPad
                    make.leading.trailing.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.height.equalTo(value)
                } else { // iPhone
                    make.top.bottom.equalToSuperview()
                    make.centerX.equalToSuperview().offset(offset)
                    make.width.equalTo(value)
                }
            }
        case .leading(let value, let offset):
            collectionView.snp.remakeConstraints { make in
                if isRegular { // iPad
                    make.top.leading.trailing.equalToSuperview()
                    make.height.equalTo(value)
                } else { // iPhone
                    make.leading.equalToSuperview().offset(offset)
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(value)
                }
            }
        }
    }
}
