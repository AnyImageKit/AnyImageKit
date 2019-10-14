//
//  VideoPreviewCell.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import MediaPlayer

protocol VideoPreviewCellDelegate: class {
    
    func videoCellDidPlay()
    func videoCellDidPlayOver()
    
}

final class VideoPreviewCell: PreviewCell {
    
    public weak var videoDelegate: VideoPreviewCellDelegate?
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(playImageView)
        playImageView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(80)
            maker.center.equalToSuperview()
        }
    }
    
    override func layout() {
        super.layout()
        playerLayer?.frame = fitFrame
    }
    
    // Play / Pause
    override func singleTapped() {
        super.singleTapped()
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        
        playImageView.isHidden = isPlaying
    }
    
    override func panScale(_ scale: CGFloat) {
        super.panScale(scale)
        UIView.animate(withDuration: 0.25) {
            self.playImageView.alpha = 0
        }
    }
    
    override func panEnded(_ exit: Bool) {
        super.panEnded(exit)
        if !exit && !isPlaying {
            UIView.animate(withDuration: 0.25) {
                self.playImageView.alpha = 1
            }
        }
    }
}

// MARK: - Public function
extension VideoPreviewCell {
    
    public func setPlayerItem(_ item: AVPlayerItem) {
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        imageView.layer.addSublayer(playerLayer!)
        playerLayer?.frame = imageView.bounds
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayOver), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    public func pause() {
        player?.pause()
        playImageView.isHidden = false
    }
    
}

// MARK: - Action
extension VideoPreviewCell {
    
    @objc private func didPlayOver() {
        super.singleTapped()
        playImageView.isHidden = false
        player?.pause()
        player?.seek(to: .zero)
    }
}
