// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

public class SKScrollViewDelegate: NSObject, UIScrollViewDelegate {
    private var observeStore: [ObjectIdentifier: SKWeakBox<UIScrollViewDelegate>] = [:]
}

public extension SKScrollViewDelegate {
    // MARK: - ObserveScroll
    
    func add(_ observer: (AnyObject & UIScrollViewDelegate)?) {
        guard let observer = observer else { return }
        observeStore[.init(observer)] = SKWeakBox(observer)
    }
    
    func add(_ observers: [AnyObject & UIScrollViewDelegate]) {
        observers.forEach(add(_:))
    }
    
    func remove(_ observer: AnyObject & UIScrollViewDelegate) {
        observeStore[.init(observer)] = nil
    }
    
    func remove(_ observers: [AnyObject & UIScrollViewDelegate]) {
        observers.forEach(remove(_:))
    }
    
}

// MARK: - scrollViewDelegate

public extension SKScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        observeStore.values.forEach { $0.value?.scrollViewDidScroll?(scrollView) }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        observeStore.values.forEach { $0.value?.scrollViewDidZoom?(scrollView) }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        observeStore.values.forEach { $0.value?.scrollViewWillBeginDragging?(scrollView) }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        observeStore.values.forEach { $0.value?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset) }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        observeStore.values.forEach { $0.value?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate) }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        observeStore.values.forEach { $0.value?.scrollViewWillBeginDecelerating?(scrollView) }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        observeStore.values.forEach { $0.value?.scrollViewDidEndDecelerating?(scrollView) }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        observeStore.values.forEach { $0.value?.scrollViewDidEndScrollingAnimation?(scrollView) }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        for box in observeStore.values {
            guard let target = box.value, let view = target.viewForZooming?(in: scrollView) else {
                continue
            }
            return view
        }
        return nil
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        observeStore.values.forEach { $0.value?.scrollViewWillBeginZooming?(scrollView, with: view) }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        observeStore.values.forEach { $0.value?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale) }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        for box in observeStore.values {
            guard let target = box.value, let result = target.scrollViewShouldScrollToTop?(scrollView), result == false else {
                continue
            }
            return result
        }
        return true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        observeStore.values.forEach { $0.value?.scrollViewDidScrollToTop?(scrollView) }
    }
    
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        observeStore.values.forEach { $0.value?.scrollViewDidChangeAdjustedContentInset?(scrollView) }
    }
}
#endif
