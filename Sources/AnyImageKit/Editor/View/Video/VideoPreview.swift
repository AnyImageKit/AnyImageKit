//
//  VideoPreview.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/19.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPreviewDelegate: AnyObject {
    
    func previewPlayerDidPlayToEndTime(_ view: VideoPreview)
}

final class VideoPreview: UIView {

    weak var delegate: VideoPreviewDelegate?
    
    var isPlaying: Bool {
        if let player = player {
            return player.rate != 0
        }
        return false
    }
    
    /// 显示图像
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = image
        view.clipsToBounds = true
        return view
    }()
    private(set) var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private var image: UIImage?
    
    init(frame: CGRect, image: UIImage?) {
        self.image = image
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = fitFrame
        playerLayer?.frame = imageView.frame
    }
}

// MARK: - Public
extension VideoPreview {
    
    public func setupPlayer(url: URL) {
        player = AVPlayer(url: url)
        player?.seek(to: .zero)
        playerLayer = AVPlayerLayer(player: player)
        layer.addSublayer(playerLayer!)
        playerLayer?.frame = imageView.frame
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    public func playOrPause() {
        if player == nil { return }
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
            imageView.isHidden = true
        }
    }
    
    public func setThumbnail(_ image: UIImage) {
        self.image = image
        layoutSubviews()
    }
    
    public func setProgress(_ progress: CGFloat) {
        if player == nil { return }
        guard let duration = player?.currentItem?.duration, duration.isValid else { return }
        imageView.isHidden = true
        let time = CMTime(seconds: duration.seconds * Double(progress), preferredTimescale: duration.timescale)
        guard time.isValid else { return }
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}

// MARK: - Private
extension VideoPreview {
    
    private func setupView() {
        addSubview(imageView)
    }
}

// MARK: - Target
extension VideoPreview {
    
    @objc private func playerDidPlayToEndTime(_ sender: Notification) {
        player?.pause()
        player?.seek(to: .zero)
        delegate?.previewPlayerDidPlayToEndTime(self)
    }
}


// MARK: - Getter
extension VideoPreview {
    var fitSize: CGSize {
        guard let image = image else { return CGSize.zero }
        let screenSize = self.bounds.size
        let scale = image.size.height / image.size.width
        var size = CGSize(width: screenSize.width, height: scale * screenSize.width)
        if size.height > screenSize.height {
            size.width = size.width * screenSize.height / size.height
            size.height = screenSize.height
        }
        return size
    }
    var fitFrame: CGRect {
        let size = fitSize
        let x = (bounds.width - size.width) > 0 ? (bounds.width - size.width) * 0.5 : 0
        let y = (bounds.height - size.height) > 0 ? (bounds.height - size.height) * 0.5 : 0
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
