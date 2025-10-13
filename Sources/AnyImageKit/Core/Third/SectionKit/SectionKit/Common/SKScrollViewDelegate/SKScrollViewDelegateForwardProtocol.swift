//
//  File.swift
//  
//
//  Created by linhey on 2024/3/14.
//

import UIKit

public protocol SKScrollViewDelegateForwardProtocol {
    // any offset changes
    @available(iOS 2.0, *)
    func scrollViewDidScroll(_ scrollView: UIScrollView) -> SKHandleResult<Void>
    // any zoom scale changes
    @available(iOS 3.2, *)
    func scrollViewDidZoom(_ scrollView: UIScrollView) -> SKHandleResult<Void>
    // called on start of dragging (may require some time and or distance to move)
    @available(iOS 2.0, *)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) -> SKHandleResult<Void>
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @available(iOS 5.0, *)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) -> SKHandleResult<Void>
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    @available(iOS 2.0, *)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) -> SKHandleResult<Void>
    // called on finger up as we are moving
    @available(iOS 2.0, *)
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) -> SKHandleResult<Void>
    // called when scroll view grinds to a halt
    @available(iOS 2.0, *)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) -> SKHandleResult<Void>
    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    @available(iOS 2.0, *)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) -> SKHandleResult<Void>
    // return a view that will be scaled. if delegate returns nil, nothing happens
    @available(iOS 2.0, *)
    func viewForZooming(in scrollView: UIScrollView) -> SKHandleResult<UIView?>
    // called before the scroll view begins zooming its content
    @available(iOS 3.2, *)
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) -> SKHandleResult<Void>
    // scale between minimum and maximum. called after any 'bounce' animations
    @available(iOS 2.0, *)
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) -> SKHandleResult<Void>
    // return a yes if you want to scroll to the top. if not defined, assumes YES
    @available(iOS 2.0, *)
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> SKHandleResult<Bool>
    @available(iOS 2.0, *)
    // called when scrolling animation finished. may be called immediately if already at top
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) -> SKHandleResult<Void>
    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) -> SKHandleResult<Void>
}

public extension SKScrollViewDelegateForwardProtocol {
    @available(iOS 2.0, *)
    func scrollViewDidScroll(_ scrollView: UIScrollView) -> SKHandleResult<Void> { .next }
    @available(iOS 3.2, *)
    func scrollViewDidZoom(_ scrollView: UIScrollView) -> SKHandleResult<Void> { .next }
    @available(iOS 2.0, *)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) -> SKHandleResult<Void> { .next }
    
    @available(iOS 5.0, *)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) -> SKHandleResult<Void> { .next }
    
    @available(iOS 2.0, *)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) -> SKHandleResult<Void> { .next }
    
    @available(iOS 2.0, *)
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) -> SKHandleResult<Void> { .next }
    
    @available(iOS 2.0, *)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) -> SKHandleResult<Void> { .next }
    
    @available(iOS 2.0, *)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) -> SKHandleResult<Void> { .next }
    
    @available(iOS 2.0, *)
    func viewForZooming(in scrollView: UIScrollView) -> SKHandleResult<UIView?> { .next }
    
    @available(iOS 3.2, *)
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) -> SKHandleResult<Void> { .next }
    
    @available(iOS 2.0, *)
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) -> SKHandleResult<Void> { .next }
    
    @available(iOS 2.0, *)
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> SKHandleResult<Bool> { .next }
    
    @available(iOS 2.0, *)
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) -> SKHandleResult<Void> { .next }
    
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) -> SKHandleResult<Void> { .next }
    
}

