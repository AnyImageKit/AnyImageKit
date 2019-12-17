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
    let colorIdx: Int
    let image: UIImage
    let inset: CGFloat
    
    var point: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: CGFloat = 0.0
    
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
        let view = UIView()
        view.isHidden = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    private(set) lazy var deleteButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isHidden = true
        view.setImage(BundleHelper.image(named: "Delete"), for: .normal)
        return view
    }()
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: image)
        return view
    }()
    
    private var timer: Timer?
    private var checkCount: Int = 0
    
    init(frame: CGRect, text: String, colorIdx: Int, image: UIImage, inset: CGFloat) {
        self.text = text
        self.colorIdx = colorIdx
        self.image = image
        self.inset = inset
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(rectView)
        addSubview(deleteButton)
        addSubview(imageView)
        rectView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(12)
        }
        deleteButton.snp.makeConstraints { (maker) in
            maker.top.right.equalToSuperview()
            maker.width.height.equalTo(25)
        }
        imageView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(inset)
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
        rectView.isHidden = !isActive
        deleteButton.isHidden = !isActive
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
