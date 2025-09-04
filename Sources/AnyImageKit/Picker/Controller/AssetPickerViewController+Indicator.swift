//
//  AssetPickerViewController+Indicator.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2025/9/4.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

extension AssetPickerViewController {
        
    /// Handle the pan gesture of the indicator.
    @objc func panIndicator(gr: UIPanGestureRecognizer) {
        if gr.state == .began {
            indicatorView.inPan = true
            showIndicator(true)
        }
        
        let point = gr.translation(in: view)
        gr.setTranslation(CGPoint(x: 0, y: 0), in: view)
        
        let newIndicatorY = indicatorView.frame.origin.y + point.y
        let newContentOffsetY = getContentOffsetY(from: newIndicatorY)
        let finalIndicatorY = getIndicatorY(from: newContentOffsetY)
        
        collectionView.contentOffset.y = newContentOffsetY
        indicatorView.snp.updateConstraints({ (make) in
            make.top.equalTo(collectionView).offset(finalIndicatorY)
        })
        
        if gr.state == .ended || gr.state == .cancelled || gr.state == .failed {
            indicatorView.inPan = false
            showIndicator(false)
        }
    }
    
    /// Update the position of the indicator.
    func updateIndicator() {
        if manager.options.scrollIndicator == .none { return }
        if indicatorView.inPan { return }
        let offset = getIndicatorY(from: collectionView.contentOffset.y)
        if offset.isNaN || offset.isInfinite { return }
        UIView.animate(withDuration: 0.1) {
            self.indicatorView.snp.updateConstraints({ (make) in
                make.top.equalTo(self.collectionView).offset(offset)
            })
        }
    }
    
    /// Show or hide the indicator and tool bar.
    func showIndicator(_ show: Bool) {
        switch manager.options.scrollIndicator {
        case .none:
            break
        case .horizontalBar:
            if show {
                indicatorView.hideIndicatorCancellable?.cancel()
                UIView.animate(withDuration: 0.25) {
                    self.indicatorView.alpha = 1
                }
            } else {
                indicatorView.hideIndicatorCancellable?.cancel()
                indicatorView.hideIndicatorCancellable = Just(())
                    .delay(for: .seconds(1.5), scheduler: RunLoop.main)
                    .sink { [weak self] in
                        UIView.animate(withDuration: 0.25) {
                            self?.indicatorView.alpha = 0
                        }
                    }
            }
        case .verticalBar:
            let hiddenToolBar = show && indicatorView.inPan
            setStatusBar(hidden: hiddenToolBar)
            UIView.animate(withDuration: 0.25) {
                self.indicatorView.indicatorImageView.alpha = show ? 1 : 0.4
                self.navigationController?.navigationBar.alpha = hiddenToolBar ? 0.01 : 1
                self.toolBar.alpha = hiddenToolBar ? 0.01 : 1
                self.permissionView.alpha = hiddenToolBar ? 0.01 : 1
                self.topDateIndicatorView.alpha = hiddenToolBar ? 1 : 0.0
            }
        }
    }
    
    func handleIndicatorWhenScrollViewDidScroll(_ scrollView: UIScrollView) {
        switch manager.options.scrollIndicator {
        case .none:
            break
        case .horizontalBar:
            indicatorView.update(getFirstVisibleAsset(), options: manager.options)
            if !indicatorView.inPan {
                updateIndicator()
            }
        case .verticalBar:
            if indicatorView.inPan {
                topDateIndicatorView.update(getFirstVisibleAsset(), options: manager.options)
            } else {
                updateIndicator()
            }
        }
    }
    
    private func getFirstVisibleAsset() -> Asset? {
        let indexPaths = collectionView.indexPathsForVisibleItems
        if let assets = album?.assets, let first = indexPaths.first {
            let asset = first.item < assets.count ? assets[first.item] : assets.first
            return asset
        }
        return nil
    }
}

// MARK: - Calculation
extension AssetPickerViewController {
    
    private func getIndicatorY(from contentOffsetY: CGFloat) -> CGFloat {
        let topSafeMargin: CGFloat = view.safeAreaInsets.top
        let bottomSafeMargin: CGFloat = permissionView.isHidden ? toolBar.frame.height : toolBar.frame.height + permissionView.frame.height
        
        let totalScrollableHeight = collectionView.contentSize.height - collectionView.frame.height + topSafeMargin + bottomSafeMargin
        guard totalScrollableHeight > 0 else { return topSafeMargin }
        
        let scrollProgress = (contentOffsetY + topSafeMargin) / totalScrollableHeight
        
        let indicatorTrackHeight = collectionView.frame.height - topSafeMargin - bottomSafeMargin - indicatorView.frame.height
        guard indicatorTrackHeight > 0 else { return topSafeMargin }
        
        var indicatorY = topSafeMargin + scrollProgress * indicatorTrackHeight
        
        let maxIndicatorY = collectionView.frame.height - bottomSafeMargin - indicatorView.frame.height
        indicatorY = max(topSafeMargin, min(indicatorY, maxIndicatorY))
        
        return indicatorY
    }

    private func getContentOffsetY(from indicatorY: CGFloat) -> CGFloat {
        let topSafeMargin: CGFloat = view.safeAreaInsets.top
        let bottomSafeMargin: CGFloat = permissionView.isHidden ? toolBar.frame.height : toolBar.frame.height + permissionView.frame.height
        
        let maxIndicatorY = collectionView.frame.height - bottomSafeMargin - indicatorView.frame.height
        let clampedIndicatorY = max(topSafeMargin, min(indicatorY, maxIndicatorY))

        let indicatorTrackHeight = collectionView.frame.height - topSafeMargin - bottomSafeMargin - indicatorView.frame.height
        guard indicatorTrackHeight > 0 else { return -topSafeMargin }

        let indicatorProgress = (clampedIndicatorY - topSafeMargin) / indicatorTrackHeight
        
        let totalScrollableHeight = collectionView.contentSize.height - collectionView.frame.height + topSafeMargin + bottomSafeMargin
        
        let contentOffsetY = indicatorProgress * totalScrollableHeight - topSafeMargin
        
        return contentOffsetY
    }
}
