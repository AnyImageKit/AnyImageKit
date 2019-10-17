//
//  VideoView.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/19.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class VideoView: UIView {
    
    private lazy var videoImageView: UIImageView = {
        let view = UIImageView()
        view.image = BundleHelper.image(named: "Video")
        return view
    }()
    private lazy var videoLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    private lazy var videoCoverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: self.bounds.height-20, width: self.bounds.width, height: 20)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoCoverLayer.frame = CGRect(x: 0, y: self.bounds.height-20, width: self.bounds.width, height: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(videoCoverLayer)
        addSubview(videoImageView)
        addSubview(videoLabel)
        
        videoImageView.snp.makeConstraints { (maker) in
            maker.left.bottom.equalToSuperview().inset(8)
            maker.width.equalTo(videoImageView.snp.height).multipliedBy(65.0/40)
            maker.height.equalTo(15)
        }
        videoLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(videoImageView.snp.right).offset(3)
            maker.centerY.equalTo(videoImageView)
        }
    }
    
}

extension VideoView {
    
    /// 设置视频时间，单位：秒
    func setVideoTime(_ time: String) {
        videoLabel.isHidden = false
        videoLabel.text = time
    }
}
