//
//  ToolCollectionView.swift
//  AnyImageKit
//
//  Created by Ray on 2022/1/22.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class ToolCollectionView: UIView {

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
        print(1)
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
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
