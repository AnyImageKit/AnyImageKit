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
        addSubview(stackView)
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

// MARK: - Private
extension VideoEditorCropProgressView {
    
    
}
