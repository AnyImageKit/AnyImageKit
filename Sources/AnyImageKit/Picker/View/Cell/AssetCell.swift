//
//  AssetCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class AssetCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var gifView: GIFView = {
        let view = GIFView()
        view.isHidden = true
        return view
    }()
    private lazy var videoView: VideoView = {
        let view = VideoView()
        view.isHidden = true
        return view
    }()
    private lazy var editedView: EditedView = {
        let view = EditedView()
        view.isHidden = true
        return view
    }()
    private lazy var selectdCoverView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    private lazy var disableCoverView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    private(set) lazy var boxCoverView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.layer.borderWidth = 4
        return view
    }()
    private(set) lazy var selectButton: NumberCircleButton = {
        let view = NumberCircleButton(frame: .zero, style: .default)
        return view
    }()
    
    private var identifier: String = ""
    
    override func prepareForReuse() {
        super.prepareForReuse()
        identifier = ""
        selectdCoverView.isHidden = true
        gifView.isHidden = true
        videoView.isHidden = true
        editedView.isHidden = true
        disableCoverView.isHidden = true
        boxCoverView.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(selectdCoverView)
        addSubview(gifView)
        addSubview(videoView)
        addSubview(editedView)
        addSubview(disableCoverView)
        addSubview(boxCoverView)
        addSubview(selectButton)
        
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectdCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        gifView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        videoView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        editedView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        disableCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        boxCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectButton.snp.makeConstraints { maker in
            maker.top.right.equalToSuperview().inset(0)
            maker.width.height.equalTo(40)
        }
    }
}

extension AssetCell {
    
    var image: UIImage? {
        return imageView.image
    }
}

extension AssetCell {
    
    private func setOptions(_ options: PickerOptionsInfo) {
        boxCoverView.layer.borderColor = options.theme.mainColor.cgColor
        selectButton.setTheme(options.theme)
        selectButton.isHidden = options.selectionTapAction.hideToolBar && options.selectLimit == 1
    }
    
    func setContent(_ asset: Asset, manager: PickerManager, animated: Bool = false, isPreview: Bool = false) {
        asset.check(disable: manager.options.disableRules)
        setOptions(manager.options)
        let options = _PhotoFetchOptions(sizeMode: .thumbnail(100*UIScreen.main.nativeScale), needCache: false)
        identifier = asset.phAsset.localIdentifier
        manager.requestPhoto(for: asset.phAsset, options: options, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard self.identifier == asset.phAsset.localIdentifier else { return }
                self.imageView.image = asset._image ?? response.image
                if asset.mediaType == .video && !isPreview {
                    self.videoView.setVideoTime(asset.durationDescription)
                }
            case .failure(let error):
                _print(error)
            }
        })
        
        updateState(asset, manager: manager, animated: animated, isPreview: isPreview)
    }
    
    func updateState(_ asset: Asset, manager: PickerManager, animated: Bool = false, isPreview: Bool = false) {
        if asset._images[.edited] != nil {
            editedView.isHidden = false
        } else {
            switch asset.mediaType {
            case .photoGIF:
                gifView.isHidden = false
            case .video:
                videoView.isHidden = false
            default:
                break
            }
        }
        
        if !isPreview {
            selectButton.setNum(asset.selectedNum, isSelected: asset.isSelected, animated: animated)
            selectdCoverView.isHidden = !asset.isSelected
            if asset.isDisable {
                disableCoverView.isHidden = false
            } else {
                disableCoverView.isHidden = !(manager.isUpToLimit && !asset.isSelected)
            }
        }
    }
}


// MARK: - VideoView
private class VideoView: UIView {
    
    private lazy var videoImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = BundleHelper.image(named: "Video", module: .picker)
        return view
    }()
    private lazy var videoLabel: UILabel = {
        let view = UILabel(frame: .zero)
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
        
        videoImageView.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(8)
            maker.width.equalTo(24)
            maker.height.equalTo(15)
        }
        videoLabel.snp.makeConstraints { maker in
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


// MARK: - GIF View
private class GIFView: UIView {

    private lazy var gifLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = "GIF"
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return view
    }()
    private lazy var gifCoverLayer: CAGradientLayer = {
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
        gifCoverLayer.frame = CGRect(x: 0, y: self.bounds.height-20, width: self.bounds.width, height: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(gifCoverLayer)
        addSubview(gifLabel)
        
        gifLabel.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(8)
            maker.height.equalTo(15)
        }
    }
}

// MARK: - Edited View
private class EditedView: UIView {

    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = BundleHelper.image(named: "PhotoEdited", module: .picker)
        return view
    }()
    private lazy var coverLayer: CAGradientLayer = {
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
        coverLayer.frame = CGRect(x: 0, y: self.bounds.height-20, width: self.bounds.width, height: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(coverLayer)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(6)
            maker.width.height.equalTo(15)
        }
    }
}

