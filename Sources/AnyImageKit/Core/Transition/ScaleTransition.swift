//
//  ScaleTransition.swift
//  AnyImageKit
//
//  Created by linhey on 9/16/25.
//

import UIKit

public class ScaleTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    public private(set) weak var presentationController: ScalePresentationController?
    public let fromView: (() -> UIView?)?
    public let toView: (() -> UIView?)?
    public let backgroundColor: UIColor
    
    public init(backgroundColor: UIColor, from: (() -> UIView?)? = nil, to: (() -> UIView?)? = nil) {
        self.fromView = from
        self.toView = to
        self.backgroundColor = backgroundColor
        super.init()
    }
    
    /// 提供进场动画
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator(direction: .presentation)
    }
    
    /// 提供退场动画
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator(direction: .dismissal)
    }
    
    /// 提供转场协调器
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ScalePresentationController(presentedViewController: presented, presenting: presenting)
        controller.maskView.backgroundColor = backgroundColor
        presentationController = controller
        return controller
    }
    
    /// 创建缩放型进场动画
    private func animator(
        direction: AnimatedTransitionDirection
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let from = fromView?(), let to = toView?() else {
            return FadeAnimator(direction: direction)
        }

        let image: UIImage?
        if let imageView = to as? UIImageView {
            image = imageView.image
        } else {
            let renderer = UIGraphicsImageRenderer(size: to.bounds.size)
            image = renderer.image { context in
                to.drawHierarchy(in: to.bounds, afterScreenUpdates: true)
            }
        }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        switch direction {
        case .presentation:
            return ScaleAnimator(startView: from, endView: to, scaleView: imageView)
        case .dismissal:
            return ScaleAnimator(startView: to, endView: from, scaleView: imageView)
        }
        
    }
}
