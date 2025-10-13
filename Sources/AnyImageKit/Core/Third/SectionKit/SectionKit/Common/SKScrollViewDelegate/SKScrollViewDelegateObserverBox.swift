//
//  File.swift
//  
//
//  Created by linhey on 2024/3/15.
//

import UIKit

/// 对 2.1.0 以下版本兼容处理
struct SKScrollViewDelegateObserverBox: SKScrollViewDelegateObserverProtocol {
   
    let box: SKWeakBox<UIScrollViewDelegate>
    var target: (any UIScrollViewDelegate)? { box.value }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView, value: Void) {
        target?.scrollViewDidScroll?(scrollView)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView, value: Void) {
        target?.scrollViewDidZoom?(scrollView)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView, value: Void) {
        target?.scrollViewWillBeginDragging?(scrollView)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, value: Void) {
        target?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool, value: Void) {
        target?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView, value: Void) {
        target?.scrollViewWillBeginDecelerating?(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView, value: Void) {
        target?.scrollViewDidEndDecelerating?(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView, value: Void) {
        target?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    func viewForZooming(in scrollView: UIScrollView, value: UIView?) -> UIView? {
        target?.viewForZooming?(in: scrollView)
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?, value: Void) {
        target?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat, value: Void) {
        target?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView, value: Bool) {
        _ = target?.scrollViewShouldScrollToTop?(scrollView)
    }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView, value: Void) {
        target?.scrollViewDidScrollToTop?(scrollView)
    }
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView, value: Void) {
        target?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}
