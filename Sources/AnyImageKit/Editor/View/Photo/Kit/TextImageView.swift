//
//  TextImageView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/10.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
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
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    private(set) lazy var deleteButton: UIButton = {
        let view = UIButton(type: .custom)
        view.isHidden = true
        view.setImage(BundleHelper.image(named: "Delete", module: .editor), for: .normal)
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
        addSubview(deleteButton)
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
            maker.edges.equalToSuperview().inset(data.inset*0.6)
        }
        deleteButton.snp.remakeConstraints { maker in
            maker.top.right.equalToSuperview()
            maker.width.height.equalTo(data.inset*1.25)
        }
        imageView.snp.makeConstraints { maker in
//            maker.edges.equalToSuperview().inset(data.inset)
            maker.edges.equalToSuperview()
        }
    }
}

extension TextImageView {
    
    public func setActive(_ isActive: Bool) {
        self.isActive = isActive
//        rectView.isHidden = !isActive
//        deleteButton.isHidden = !isActive
//        if isActive && timer == nil {
//            checkCount = 0
//            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkActive(_:)), userInfo: nil, repeats: true)
//        }
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
