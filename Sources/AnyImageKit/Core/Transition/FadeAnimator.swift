//
//  FadeAnimator.swift
//  AnyImageKit
//
//  Created by Codex on 2026/6/5.
//

import UIKit

final class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let direction: AnimatedTransitionDirection

    init(direction: AnimatedTransitionDirection) {
        self.direction = direction
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch direction {
        case .presentation:
            animatePresentation(using: transitionContext)
        case .dismissal:
            animateDismissal(using: transitionContext)
        }
    }
}

private extension FadeAnimator {

    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        toView.frame = containerView.bounds
        toView.alpha = 0
        containerView.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.alpha = 1
        }, completion: { _ in
            let completed = !transitionContext.transitionWasCancelled
            if !completed {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(completed)
        })
    }

    func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        fromView.alpha = 1
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.alpha = 0
        }, completion: { _ in
            let completed = !transitionContext.transitionWasCancelled
            if !completed {
                fromView.alpha = 1
            }
            transitionContext.completeTransition(completed)
        })
    }
}
