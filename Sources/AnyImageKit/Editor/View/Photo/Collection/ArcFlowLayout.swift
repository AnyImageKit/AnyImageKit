//
//  ArcFlowLayout.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/4.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class ArcFlowLayout: UICollectionViewFlowLayout {
    
    var autoScrollToItem: Bool = true
    
    var isRegular: Bool = true
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, autoScrollToItem else { return proposedContentOffset }
        
        if isRegular {
            var targetPoint = proposedContentOffset
            let centerY = proposedContentOffset.y + collectionView.bounds.height / 2
            let attrs = self.layoutAttributesForElements(in: CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            
            var moveDistance: CGFloat = CGFloat(MAXFLOAT)
            attrs!.forEach { (attr) in
                if abs(attr.center.y - centerY) < abs(moveDistance) {
                    moveDistance = attr.center.y - centerY
                }
            }
            
            if targetPoint.y > 0 && targetPoint.y < collectionViewContentSize.height - collectionView.bounds.height {
                targetPoint.y += moveDistance
            }
            return targetPoint
        } else {
            var targetPoint = proposedContentOffset
            let centerX = proposedContentOffset.x + collectionView.bounds.width / 2
            let attrs = self.layoutAttributesForElements(in: CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            
            var moveDistance: CGFloat = CGFloat(MAXFLOAT)
            attrs!.forEach { (attr) in
                if abs(attr.center.x - centerX) < abs(moveDistance) {
                    moveDistance = attr.center.x - centerX
                }
            }
            
            if targetPoint.x > 0 && targetPoint.x < collectionViewContentSize.width - collectionView.bounds.width {
                targetPoint.x += moveDistance
            }
            return targetPoint
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        let count = CGFloat(collectionView?.numberOfItems(inSection: 0) ?? 0)
        if isRegular {
            return CGSize(width: itemSize.width, height: sectionInset.top + sectionInset.bottom + (count * (itemSize.height + minimumLineSpacing)) - minimumLineSpacing)
        } else {
            return CGSize(width: sectionInset.left + sectionInset.right + (count * (itemSize.width + minimumLineSpacing)) - minimumLineSpacing, height: 0)
        }
    }
}
