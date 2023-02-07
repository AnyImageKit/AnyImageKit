//
//  Toast.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2022/11/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class Toast: UIView {
    
    static let shared = Toast()
    
    private var message: String = ""
    private var timer: Timer?
    
    private let widthScale = 0.7
    private let radius = 8.0
    private lazy var textMargin = radius + 5.0
    
    private var font: UIFont = {
        return UIDevice.current.userInterfaceIdiom == .phone ? .systemFont(ofSize: 15) : .systemFont(ofSize: 18)
    }()
    
    private var completion: (() -> Void)?
    
    public override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        UIColor.color(r: 0.0, g: 0.0, b: 0.0, a: 0.8).setFill()
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        ctx?.addPath(path.cgPath)
        path.fill()
        
        UIColor.white.setFill()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        (message as NSString).draw(in: rect.insetBy(dx: textMargin, dy: textMargin),
                                   withAttributes: [NSAttributedString.Key.font : font,
                                                    NSAttributedString.Key.paragraphStyle : paragraphStyle,
                                                    NSAttributedString.Key.foregroundColor : UIColor.white])
    }
}

// MARK: - Public
extension Toast {
    
    public static func show(message: String?, in view: UIView? = nil, duration: TimeInterval = 1.5, offset: CGPoint = .zero, completion: (() -> Void)? = nil) {
        shared.show(message: message ?? "", in: view, duration: duration, offset: offset, completion: completion)
    }
}

// MARK: - Private
extension Toast {
    
    private func show(message: String, in view: UIView?, duration: TimeInterval, offset: CGPoint, completion: (() -> Void)?) {
        guard let sourceView = (view ?? UIViewController.current?.view), !message.isEmpty else { return }
        self.completion = completion
        
        backgroundColor = .clear
        removeFromSuperview()
        timer?.invalidate()
        timer = nil
        self.message = message
        setNeedsDisplay()
        
        var frame = sourceView.bounds
        let originalWidth = frame.width
        frame.size.width *= widthScale
        frame.origin.x += (originalWidth * (1 - widthScale)) / 2
        
        let tmp = message.boundingRect(with: CGSize(width: frame.width - textMargin * 2, height: frame.height - textMargin * 2),
                                       options: .usesLineFragmentOrigin,
                                       attributes: [NSAttributedString.Key.font : font],
                                       context: nil)
        
        let size = tmp.size
        let yOffset: CGFloat = (frame.height - size.height - textMargin * 2) / 2
        frame.size.height = ceil(size.height + textMargin * 2)
        frame.origin.y = floor(yOffset + offset.y)
        let xOffset: CGFloat = (frame.width - size.width - textMargin * 2) / 2
        frame.size.width = ceil(size.width + textMargin * 2)
        frame.origin.x = floor(frame.origin.x + xOffset + offset.x)
        self.frame = frame
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(onTimer(_:)), userInfo: nil, repeats: false)
        sourceView.addSubview(self)
        alpha = 1.0
    }
    
}

extension Toast {
    
    @objc private func onTimer(_ timer: Timer) {
        completion?()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
