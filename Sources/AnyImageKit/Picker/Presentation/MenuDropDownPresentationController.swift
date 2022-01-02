//
//  MenuDropDownPresentationController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/18.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class MenuDropDownPresentationController: UIPresentationController {
    
    private var dimmingView: UIView?
    private var presentationWrappingView: UIView?
    private var opaqueView: UIView?
    
    
    var isFullScreen = true
    var extraTopMenuHeight: CGFloat = 0
    var cornerRadius: CGFloat = 0
    var corners: UIRectCorner = .allCorners
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
    }
    
    private lazy var topOffsetHeight: CGFloat = calculateTopOffsetHeight()
    private lazy var bottomOffsetHeight: CGFloat = calculateBottomOffsetHeight()
    private lazy var navigationBarHeight: CGFloat = calculateNavigationBarHeight()
    
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
            // opaque area
            let opaqueViewFrame = calculateOpaqueViewFrame()
            let opaqueView = UIView(frame: opaqueViewFrame)
            opaqueView.isOpaque = false
            opaqueView.backgroundColor = UIColor.black
            opaqueView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.opaqueView = opaqueView
            // clickable area
            let dimmingView = UIView(frame: containerView.bounds)
            dimmingView.addSubview(opaqueView)
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
        let presentedViewControllerFrame = CGRect(x: (containerViewBounds.width - presentedViewContentSize.width)/2,
                                                  y: topOffsetHeight + navigationBarHeight + extraTopMenuHeight,
                                                  width: presentedViewContentSize.width,
                                                  height: presentedViewContentSize.height)
        return presentedViewControllerFrame
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView?.frame = containerView?.bounds ?? .zero
        presentationWrappingView?.frame = frameOfPresentedViewInContainerView
    }
    
    private func calculateTopOffsetHeight() -> CGFloat {
        if isFullScreen {
            #if targetEnvironment(macCatalyst)
            return 28
            #else
            return ScreenHelper.statusBarFrame.height
            #endif
        } else {
            if traitCollection.horizontalSizeClass == .compact {
                return abs(presentingViewController.view.bounds.height - (containerView?.bounds.height ?? 0))
            } else {
                return abs(presentingViewController.view.bounds.height - (containerView?.bounds.height ?? 0))/2
            }
        }
    }
    
    private func calculateBottomOffsetHeight() -> CGFloat {
        if isFullScreen {
            return 0
        } else {
            if traitCollection.horizontalSizeClass == .compact {
                return 0
            } else {
                return abs(presentingViewController.view.bounds.height - (containerView?.bounds.height ?? 0))/2
            }
        }
    }
    
    private func calculateNavigationBarHeight() -> CGFloat {
        var bounds: CGRect?
        if let navigationController = presentingViewController as? UINavigationController {
            bounds = navigationController.topViewController?.navigationController?.navigationBar.bounds
        } else {
            bounds = presentingViewController.navigationController?.navigationBar.bounds
        }
        return bounds?.height ?? .zero
    }
    
    private func calculateOpaqueViewFrame() -> CGRect {
        guard let containerView = containerView else { return .zero }
        var rect = containerView.bounds
        rect.size.height -= (topOffsetHeight + navigationBarHeight + extraTopMenuHeight)
        rect.origin.y += (topOffsetHeight + navigationBarHeight + extraTopMenuHeight)
        if !isFullScreen {
            rect.origin.x = abs(presentingViewController.view.frame.width - containerView.bounds.width)/2
            rect.size.width = presentingViewController.view.frame.width
            rect.size.height -= bottomOffsetHeight
        }
        return rect
    }
}

// MARK: - Tap Gesture Recognizer

extension MenuDropDownPresentationController {
    
    @objc private func dimmingViewTapped(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
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
            toViewInitialFrame.origin = CGPoint(x: toViewFinalFrame.origin.x, y: topOffsetHeight + navigationBarHeight + extraTopMenuHeight)
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
            fromViewFinalFrame.origin = CGPoint(x: fromView.frame.origin.x, y: topOffsetHeight + navigationBarHeight + extraTopMenuHeight)
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
