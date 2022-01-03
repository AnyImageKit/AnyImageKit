//
//  TextImageView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/10.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class TextImageView: UIView {
    
    let data: TextData
    
    var isGestureEnded: Bool {
        for gesture in gestureRecognizers ?? [] {
            if gesture.state == .changed {
                return false
            }
        }
        return true
    }
    
    /// 激活
    private(set) var isActive: Bool = false
    
    private lazy var rectView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.layer.cornerRadius = 1
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: data.image)
        return view
    }()
    
    private var timer: Timer?
    private var checkCount: Int = 0
    
    init(data: TextData) {
        self.data = data
        super.init(frame: data.frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(rectView)
        addSubview(imageView)
    }
    
    func calculateTransform() -> CGAffineTransform {
        return CGAffineTransform.identity
            .translatedBy(x: data.point.x, y: data.point.y)
            .scaledBy(x: data.scale, y: data.scale)
            .rotated(by: data.rotation)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rectView.snp.remakeConstraints { maker in
            maker.edges.equalToSuperview().inset(-10)
        }
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let inset: CGFloat = 50
        let directionList = Direction.allCases
        for direction in directionList {
            let newPoint = direction.newPoint(with: point, offset: inset)
            let convertedPoint = imageView.convert(newPoint, from: self)
            if imageView.point(inside: convertedPoint, with: event) {
                return self
            }
        }
        return super.hitTest(point, with: event)
    }
}

extension TextImageView {
    
    public func setActive(_ isActive: Bool) {
        self.isActive = isActive
        rectView.isHidden = !isActive
        if isActive && timer == nil {
            checkCount = 0
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkActive(_:)), userInfo: nil, repeats: true)
        }
    }
}
 
// MARK: - Target
extension TextImageView {
    
    @objc private func checkActive(_ timer: Timer) {
        if self.timer == nil || !self.isActive {
            timer.invalidate()
            self.timer = nil
            return
        }
        checkCount = !isGestureEnded ? 0 : checkCount + 1
        if checkCount >= 4 {
            setActive(false)
            timer.invalidate()
            self.timer = nil
        }
    }
}

extension TextImageView {
    
    private enum Direction: CaseIterable {
        case origin
        case top
        case left
        case right
        case bottom
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        
        func newPoint(with point: CGPoint, offset: CGFloat) -> CGPoint {
            switch self {
            case .origin:
                return point
            case .top:
                return CGPoint(x: point.x, y: point.y - offset)
            case .left:
                return CGPoint(x: point.x - offset, y: point.y)
            case .right:
                return CGPoint(x: point.x + offset, y: point.y)
            case .bottom:
                return CGPoint(x: point.x, y: point.y + offset)
            case .topLeft:
                return CGPoint(x: point.x - offset, y: point.y - offset)
            case .topRight:
                return CGPoint(x: point.x + offset, y: point.y - offset)
            case .bottomLeft:
                return CGPoint(x: point.x - offset, y: point.y + offset)
            case .bottomRight:
                return CGPoint(x: point.x + offset, y: point.y + offset)
            }
        }
    }
}
