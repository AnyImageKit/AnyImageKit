//
//  VideoPreviewCell.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import MediaPlayer

final class VideoPreviewCell: PreviewCell {
    
    /// 取图片适屏size
    override var fitSize: CGSize {
        guard let image = imageView.image else { return CGSize.zero }
        let width = scrollView.bounds.width
        var size: CGSize = .zero
        if image.size.height > image.size.width {
            let scale = image.size.height / image.size.width
            size = CGSize(width: width, height: scale * width)
            let screenSize = UIScreen.main.bounds.size
            if size.width > size.height {
                size.width = size.width * screenSize.height / size.height
                size.height = screenSize.height
            }
        } else {
            let scale = image.size.height / image.size.width
            size = CGSize(width: width, height: width * scale)
        }
        return size
    }
    
    public var isPlaying: Bool {
        if let player = player {
            return player.rate != 0
        }
        return false
    }
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private lazy var playImageView: UIImageView = {
        return UIImageView(image: BundleHelper.image(named: "VideoPlay"))
    }()
    
    private lazy var iCloudView: LoadingiCloudView = {
        let view = LoadingiCloudView()
        view.isHidden = true
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
        addSubview(playImageView)
        addSubview(iCloudView)
        
        playImageView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(80)
            maker.center.equalToSuperview()
        }
        iCloudView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(100)
            maker.left.equalToSuperview().offset(5)
            maker.height.equalTo(20)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        iCloudView.reset()
    }
    
    override func layout() {
        super.layout()
        playerLayer?.frame = fitFrame
    }
    
    /// 重置
    override func reset() {
        setPlayButton(hidden: false)
        player?.pause()
        player?.seek(to: .zero)
    }
    
    /// 单击事件触发时，处理播放和暂停的逻辑
    override func singleTapped() {
        let toolBarIsHidden = delegate?.previewCellGetToolBarHiddenState() ?? true
        if player == nil {
            super.singleTapped()
        } else {
            if !toolBarIsHidden && isPlaying { // 工具栏展示 && 在播放视频 -> 暂停视频
                player?.pause()
            } else if toolBarIsHidden && !isPlaying { // 工具栏隐藏 && 未播放视频 -> 播放视频
                player?.play()
            } else {
                super.singleTapped()
                if isPlaying {
                    player?.pause()
                } else {
                    player?.play()
                }
            }
        }
        
        self.setPlayButton(hidden: isPlaying)
    }
    
    override func panScale(_ scale: CGFloat) {
        super.panScale(scale)
        UIView.animate(withDuration: 0.25) {
            self.setPlayButton(hidden: true, animated: true)
        }
    }
    
    override func panEnded(_ exit: Bool) {
        super.panEnded(exit)
        if !exit && !isPlaying {
            self.setPlayButton(hidden: false, animated: true)
        }
    }
}

// MARK: - Public function
extension VideoPreviewCell {
    
    /// 暂停
    public func pause() {
        player?.pause()
        setPlayButton(hidden: false)
    }
    
    /// 加载图片
    public func requestPhoto() {
        let options = PhotoFetchOptions(sizeMode: .resize(500))
        PhotoManager.shared.requestPhoto(for: asset.phAsset, options: options) { [weak self] result in
            switch result {
            case .success(let response):
                if !response.isDegraded {
                    self?.setImage(response.image)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // 加载视频
    public func requestVideo() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let options = VideoFetchOptions(isNetworkAccessAllowed: true) { [weak self] (progress, error, isAtEnd, info) in
                print(progress)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.setDownloadingProgress(progress)
                }
            }
            PhotoManager.shared.requestVideo(for: self.asset.phAsset, options: options) { [weak self] result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.setPlayerItem(response.playerItem)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    public func setCloudLabelColor(_ color: UIColor) {
        iCloudView.setLabelColor(color)
    }
}

// MARK: - Private function
extension VideoPreviewCell {
    
    /// 设置 PlayerItem
    private func setPlayerItem(_ item: AVPlayerItem) {
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        imageView.layer.addSublayer(playerLayer!)
        playerLayer?.frame = imageView.bounds
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayOver), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    /// 设置 iCloud 下载进度
    private func setDownloadingProgress(_ progress: Double) {
        iCloudView.isHidden = progress == 1
        iCloudView.setProgress(progress)
    }
    
    /// 设置播放按钮的展示状态
    private func setPlayButton(hidden: Bool, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.playImageView.alpha = hidden ? 0 : 1
            }
        } else {
            playImageView.alpha = hidden ? 0 : 1
        }
    }
}

// MARK: - Action
extension VideoPreviewCell {
    
    @objc private func didPlayOver() {
        super.singleTapped()
        reset()
    }
}
