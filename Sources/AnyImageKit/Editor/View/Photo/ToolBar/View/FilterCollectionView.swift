//
//  FilterCollectionView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/5.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class FilterCollectionView: ArcBaseCollectionView {
    
    let images: [UIImage]
    let selectedEvent = CurrentValueSubject<Int, Never>(0)
    
    init(option: ArcOption, images: [UIImage]) {
        self.images = images
        super.init(option: option)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch selectedIndex {
        case .index(let index):
            collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: isRegular ? .centeredVertically : .centeredHorizontally)
        case .present:
            break
        }
    }
}

// MARK: - UI
extension FilterCollectionView {
    
    private func setupView() {
        collectionView.registerCell(FilterCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.autoScrollToItem = true
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension FilterCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: isRegular ? .centeredVertically : .centeredHorizontally)
        selectedIndex = .index(indexPath.row)
        selectedEvent.send(selectedIndex.index)
    }
}

// MARK: - UICollectionViewDataSource
extension FilterCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(FilterCollectionCell.self, for: indexPath)
        cell.config(size: option.size.reversed(isRegular), image: images[indexPath.row], hiddenDot: dotIndex != indexPath.row, isRegular: isRegular)
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension FilterCollectionView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectedIndex = .index(Int(floor(max(scrollView.contentOffset.x, scrollView.contentOffset.y) / size.width)))
        selectedEvent.send(selectedIndex.index)
    }
}
