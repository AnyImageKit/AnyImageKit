//
//  TextImageView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/10.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class TextImageView: UIView {
    
    let text: String
    let image: UIImage
    
    var point: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: CGFloat = 0.0
    
    var isGestureEnded: Bool {
        return gestureState[.pan] != .changed && gestureState[.pinch] != .changed && gestureState[.rotation] != .changed
    }
    
    /// 激活
    private(set) var isActive: Bool = false
    /// 手势状态
    private(set) var gestureState: [Gesture:GestureState] = [.pan:.ended, .pinch:.ended, .rotation:.ended]
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: image)
        return view
    }()
    
    init(frame: CGRect, text: String, image: UIImage) {
        self.text = text
        self.image = image
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(10)
        }
    }
    
    func calculateTransform() -> CGAffineTransform {
        return CGAffineTransform.identity
            .translatedBy(x: point.x, y: point.y)
            .scaledBy(x: scale, y: scale)
            .rotated(by: rotation)
    }
}

extension TextImageView {
    
    public func setActive(_ isActive: Bool) {
        self.isActive = isActive
        layer.borderWidth = isActive ? 0.5 : 0.0
        layer.borderColor = UIColor.white.cgColor
    }
    
    public func updateGesture(_ gesture: Gesture, state: UIGestureRecognizer.State) {
        let _state: GestureState
        switch state {
        case .began:
            _state = .began
        case .changed:
            _state = .changed
        default:
            _state = .ended
        }
        gestureState[gesture] = _state
    }
}

extension TextImageView {
    
    enum Gesture: Hashable {
        case pan
        case pinch
        case rotation
    }
    
    enum GestureState {
        case began
        case changed
        case ended
    }
}
