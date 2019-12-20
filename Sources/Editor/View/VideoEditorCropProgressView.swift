//
//  VideoEditorCropProgressView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/19.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class VideoEditorCropProgressView: UIView {

    private(set) lazy var leftButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "VideoCropLeftWhite"), for: .normal)
        view.setImage(BundleHelper.image(named: "VideoCropLeftBlack"), for: .selected)
        return view
    }()
    private(set) lazy var rightButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "VideoCropRightWhite"), for: .normal)
        view.setImage(BundleHelper.image(named: "VideoCropRightBlack"), for: .selected)
        return view
    }()
    private lazy var progressView: ProgressView = {
        let view = ProgressView(frame: .zero)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(progressViewPan(_:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    private(set) var left: CGFloat = 0
    private(set) var right: CGFloat = 1
    
    private var previews: [UIImageView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func setupView() {
        addSubview(progressView)
        addSubview(leftButton)
        addSubview(rightButton)
        
        leftButton.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.left.equalToSuperview()
            maker.width.equalTo(20)
        }
        rightButton.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.right.equalToSuperview()
            maker.width.equalTo(20)
        }
        progressView.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview().inset(3)
            maker.width.equalTo(20)
            maker.left.equalToSuperview().offset(20-7.5)
        }
    }
    
    private func layout() {
        leftButton.snp.updateConstraints { (maker) in
            maker.left.equalToSuperview().offset(left*bounds.width)
        }
        rightButton.snp.updateConstraints { (maker) in
            maker.right.equalToSuperview().offset(-(1-right)*bounds.width)
        }
    }
}

// MARK: - Public
extension VideoEditorCropProgressView {
    
    public func setupProgressImages(_ count: Int, image: UIImage?) {
        previews = (0..<count).map{ _ in UIImageView(image: image) }
        let stackView = UIStackView(arrangedSubviews: previews)
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        insertSubview(stackView, at: 0)
        stackView.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview().inset(5)
            maker.left.right.equalToSuperview().inset(20)
        }
    }
    
    public func setProgressImage(_ image: UIImage, idx: Int) {
        guard idx < previews.count else { return }
        self.previews[idx].setImage(image, animated: true)
    }
}

// MARK: - Target
extension VideoEditorCropProgressView {
    
    @objc private func progressViewPan(_ pan: UIPanGestureRecognizer) {
        pan.location(in: <#T##UIView?#>)
        let newPoint = pan.translation(in: self)
        pan.setTranslation(.zero, in: self)
        let offset = progressView.frame.origin.x + newPoint.x
        if offset < 20-7.5 || offset > bounds.width-40+7.5 {
            return
        }
        progressView.snp.updateConstraints { (maker) in
            maker.left.equalToSuperview().offset(offset)
        }
    }
}


// MARK: - ProgressView
private final class ProgressView: UIView {
    
    private(set) lazy var whiteView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.backgroundColor = UIColor.white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(whiteView)
        whiteView.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.width.equalTo(5)
            maker.centerX.equalToSuperview()
        }
    }
}
