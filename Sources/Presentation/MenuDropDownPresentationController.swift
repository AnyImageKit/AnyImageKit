//
//  MenuDropDownPresentationController.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class MenuDropDownPresentationController: UIPresentationController {
    
    private var dimmingView: UIView?
    private var presentationWrappingView: UIView?
    
    var navigationHeight: CGFloat = 88
    var menuHeight: CGFloat = 0
    var cornerRadius: CGFloat = 0
    var corners: UIRectCorner = .allCorners
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
    }
    
    override var presentedView: UIView? {
        return presentationWrappingView
    }
    
    override func presentationTransitionWillBegin() {
        let presentedViewControllerView = super.presentedView
        
        let presentationWrapperView = UIView(frame: frameOfPresentedViewInContainerView)
        self.presentationWrappingView = presentationWrapperView
        
        let presentationRoundedCornerView = UIView(frame: presentationWrapperView.bounds)
        presentationRoundedCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentationRoundedCornerView.layer.masksToBounds = true
        
        if cornerRadius > 0 {
            let maskPath = UIBezierPath(roundedRect: presentationRoundedCornerView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = presentationRoundedCornerView.bounds
            maskLayer.path = maskPath.cgPath
            presentationRoundedCornerView.layer.mask = maskLayer
        }
        
        let presentedViewControllerWrapperView = UIView(frame: presentationRoundedCornerView.bounds)
        presentedViewControllerWrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let presentedViewControllerView = presentedViewControllerView {
            presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds
            presentedViewControllerWrapperView.addSubview(presentedViewControllerView)
        }
        
        presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
        presentationWrapperView.addSubview(presentationRoundedCornerView)
        
        // mask
        if let containerView = containerView {
            // clear area
            var topRect = containerView.bounds
            topRect.size.height = navigationHeight + menuHeight
            let topOpaqueView = UIView(frame: topRect)
            topOpaqueView.isOpaque = false
            topOpaqueView.backgroundColor = UIColor.clear
            topOpaqueView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // opaque area
            var bottomRect = containerView.bounds
            bottomRect.size.height -= (navigationHeight + menuHeight)
            bottomRect.origin.y += (navigationHeight + menuHeight)
            let bottomOpaqueView = UIView(frame: bottomRect)
            bottomOpaqueView.isOpaque = false
            bottomOpaqueView.backgroundColor = UIColor.black
            bottomOpaqueView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // clickable area
            let dimmingView = UIView(frame: containerView.bounds)
            dimmingView.addSubview(topOpaqueView)
            dimmingView.addSubview(bottomOpaqueView)
            dimmingView.isOpaque = false
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let gesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:)))
            dimmingView.addGestureRecognizer(gesture)
            self.dimmingView = dimmingView
            containerView.addSubview(dimmingView)
            dimmingView.alpha = 0
            presentingViewController.transitionCoordinator?.animate(alongsideTransition: { context in
                dimmingView.alpha = 0.5
            }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            presentationWrappingView = nil
            dimmingView = nil
        }
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView?.alpha = 0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentationWrappingView = nil
            dimmingView = nil
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if presentedViewController == (container as? UIViewController) {
            containerView?.setNeedsLayout()
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if presentedViewController == (container as? UIViewController) {
            return (container as? UIViewController)?.preferredContentSize ?? .zero
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerViewBounds = containerView?.bounds ?? .zero
        let presentedViewContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerViewBounds.size)
        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size.height = presentedViewContentSize.height
        presentedViewControllerFrame.size.width = containerViewBounds.width
        presentedViewControllerFrame.origin.x = 0
        presentedViewControllerFrame.origin.y = navigationHeight + menuHeight
        return presentedViewControllerFrame
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView?.frame = containerView?.bounds ?? .zero
        presentationWrappingView?.frame = frameOfPresentedViewInContainerView
    }
}

// MARK: - Tap Gesture Recognizer

extension MenuDropDownPresentationController {
    
    @objc private func dimmingViewTapped(_ sender: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension MenuDropDownPresentationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let isAnimated = transitionContext?.isAnimated ?? false
        return isAnimated ? 0.25 : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        let isPresenting: Bool = fromViewController == presentingViewController
        let duration = transitionDuration(using: transitionContext)
        
        if isPresenting {
            guard let toView = transitionContext.view(forKey: .to) else { return }
            containerView.addSubview(toView)
            var toViewInitialFrame = transitionContext.initialFrame(for: toViewController)
            let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
            toViewInitialFrame.origin = CGPoint(x: 0, y: navigationHeight + menuHeight)
            toViewInitialFrame.size = CGSize(width: toViewFinalFrame.width, height: 0)
            toView.frame = toViewInitialFrame
            // animation
            UIView.animate(withDuration: duration, animations: {
                toView.frame = toViewFinalFrame
            }, completion: { finished in
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
            })
        } else {
            guard let fromView = transitionContext.view(forKey: .from) else { return }
            var fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController)
            fromViewFinalFrame.origin = CGPoint(x: 0, y: navigationHeight + menuHeight)
            fromViewFinalFrame.size.height = 0
            // animation
            UIView.animate(withDuration: duration, animations: {
                fromView.frame = fromViewFinalFrame
                fromView.layoutIfNeeded()
            }, completion: { finished in
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
            })
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension MenuDropDownPresentationController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(presentedViewController == presented)
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
