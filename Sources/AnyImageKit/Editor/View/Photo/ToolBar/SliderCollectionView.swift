//
//  SliderCollectionView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/5.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class SliderCollectionView: ArcBaseCollectionView {
    
    @Injected(\.photoOptions)
    private var photoOptions: EditorPhotoOptionsInfo
    
    let count: Int
    
    init(option: ArcOption, count: Int) {
        self.count = count
        super.init(option: option)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch selectedIndex {
        case .index:
            break
        case .present(let present):
            collectionView.contentOffset = offset(of: present)
        }
    }
    
    override func updateLayout(isRegular: Bool) {
        super.updateLayout(isRegular: isRegular)
        guard isRegular != preIsRegular else { return }
        selectedIndex = .present(1-selectedIndex.value)
    }
}

extension SliderCollectionView {
    
    private func setupView() {
        collectionView.registerCell(SliderCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.autoScrollToItem = false
    }
}

// MARK: - UICollectionViewDelegate
extension SliderCollectionView: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension SliderCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(SliderCollectionCell.self, for: indexPath)
        let dotIdx = isRegular ? (count - 1 - dotIndex) : dotIndex
        cell.config(size: option.size.reversed(isRegular), highlight: indexPath.row % 10 == 0, hiddenDot: dotIdx != indexPath.row, isRegular: isRegular)
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension SliderCollectionView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectedIndex = .present(present(of: scrollView.contentOffset))
        centerView.backgroundColor = photoOptions.theme[color: .primary]
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.15, delay: 0.15, options: [], animations: {
            self.centerView.backgroundColor = .white
        }, completion: nil)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        UIView.animate(withDuration: 0.15, delay: 0.15, options: [], animations: {
            self.centerView.backgroundColor = .white
        }, completion: nil)
    }
}

extension SliderCollectionView {
    
    private func present(of offset: CGPoint) -> CGFloat {
        let offsetValue = isRegular ? collectionView.contentOffset.y : collectionView.contentOffset.x
        let margin = max(flowLayout.sectionInset.top, flowLayout.sectionInset.left) * 2
        let size = (isRegular ? flowLayout.collectionViewContentSize.height : flowLayout.collectionViewContentSize.width) - margin
        return offsetValue / size
    }
    
    private func offset(of present: CGFloat) -> CGPoint {
        let margin = max(flowLayout.sectionInset.top, flowLayout.sectionInset.left) * 2
        let size = (isRegular ? flowLayout.collectionViewContentSize.height : flowLayout.collectionViewContentSize.width) - margin
        let offsetValue = present * size
        return isRegular ? CGPoint(x: 0, y: offsetValue) : CGPoint(x: offsetValue, y: 0)
    }
}
