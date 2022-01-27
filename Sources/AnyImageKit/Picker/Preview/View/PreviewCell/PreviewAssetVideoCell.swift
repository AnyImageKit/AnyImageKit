//
//  PreviewAssetVideoCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import AVFoundation

final class PreviewAssetVideoCell: PreviewAssetContentCell {
    
    private lazy var iconView: UIImageView = makeIconView()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private var task: Task<Void, Error>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
    }
    
    override func optionsDidUpdate(options: PickerOptionsInfo) {
        iconView.image = options.theme[icon: .videoPlay]
        accessibilityLabel = options.theme[string: .video]
    }
}

// MARK: PreviewAssetContent
extension PreviewAssetVideoCell {
    
    var fitSize: CGSize {
        guard let image = imageView.image else { return CGSize.zero }
        let width = scrollView.bounds.width
        var size: CGSize = .zero
        if image.size.height > image.size.width {
            let scale = image.size.height / image.size.width
            size = CGSize(width: width, height: scale * width)
            let screenSize = ScreenHelper.mainBounds.size
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
    
    func layoutDidUpdate() {
        playerLayer?.frame = imageView.bounds
    }
    
    func singleTapped() {
        let toolBarIsHidden = /* delegate?.previewCellGetToolBarHiddenState() ??*/ true
        if player == nil {
            sendSingleTappedEvent()
        } else {
            if !toolBarIsHidden && isPlaying { // 工具栏展示 && 在播放视频 -> 暂停视频
                player?.pause()
            } else if toolBarIsHidden && !isPlaying { // 工具栏隐藏 && 未播放视频 -> 播放视频
                player?.play()
            } else {
                sendSingleTappedEvent()
                if isPlaying {
                    player?.pause()
                } else {
                    player?.play()
                }
            }
        }
        
        self.setPlayButton(hidden: isPlaying)
    }
    
    func panScale(_ scale: CGFloat) {
        sendPanEvent(state: .scale(scale))
        setPlayButton(hidden: true, animated: true)
    }
    
    func panEnded(_ exit: Bool) {
        sendPanEvent(state: .end(exit))
        if !exit && !isPlaying {
            setPlayButton(hidden: false, animated: true)
        }
    }
    
    func resetContent() {
        setPlayButton(hidden: false)
        imageView.image = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
    }
    
    func setContent<Resource>(asset: Asset<Resource>) where Resource: IdentifiableResource, Resource: LoadableResource {
        task?.cancel()
        task = Task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await self.loadCover(asset: asset)
                }
                group.addTask {
                    try await self.loadVideo(asset: asset)
                }
            }
        }
    }
    
    @MainActor
    private func loadCover<Resource>(asset: Asset<Resource>) async throws where Resource: IdentifiableResource, Resource: LoadableResource {
        let targetSize = frame.size.displaySize
        for try await result in asset.loadImage(options: .init(targetSize: targetSize)) {
            switch result {
            case .progress:
                break
            case .success(let loadResult):
                switch loadResult {
                case .thumbnail(let image):
                    setImage(image)
                case .preview(let image):
                    setImage(image)
                default:
                    break
                }
            }
        }
    }
    
    @MainActor
    private func loadVideo<Resource>(asset: Asset<Resource>) async throws where Resource: IdentifiableResource, Resource: LoadableResource {
        for try await result in asset.loadVideo() {
            switch result {
            case .progress(let progress):
                _print("Loading video: \(progress)")
                updateLoadingProgress(progress)
            case .success(let loadResult):
                switch loadResult {
                case .video(let avAsset, _):
                    let playerItem = AVPlayerItem(asset: avAsset)
                    setPlayerItem(playerItem)
                    updateLoadingProgress(1.0)
                default:
                    break
                }
            }
        }
    }
}

// MARK: UI Setup
extension PreviewAssetVideoCell {
    
    private func setupView() {
        addSubview(iconView)
        iconView.snp.makeConstraints { maker in
            maker.width.height.equalTo(80)
            maker.center.equalToSuperview()
        }
    }
    
    private func makeIconView() -> UIImageView {
        let view = UIImageView(frame: .zero)
        return view
    }
}

// MARK: - Function
extension PreviewAssetVideoCell {
    
    /// 暂停
    func pause() {
        player?.pause()
        setPlayButton(hidden: false)
    }
}

// MARK: - Private function
extension PreviewAssetVideoCell {
    
    private var isPlaying: Bool {
        if let player = player {
            return player.rate != 0
        }
        return false
    }
    
    /// 设置 PlayerItem
    private func setPlayerItem(_ item: AVPlayerItem) {
        let player = AVPlayer(playerItem: item)
        let playerLayer = AVPlayerLayer(player: player)
        imageView.layer.addSublayer(playerLayer)
        playerLayer.frame = imageView.bounds
        
        self.player = player
        self.playerLayer = playerLayer
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    /// 设置播放按钮的展示状态
    private func setPlayButton(hidden: Bool, animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.iconView.alpha = hidden ? 0 : 1
        }
    }
}

// MARK: - Action
extension PreviewAssetVideoCell {
    
    @objc private func playerDidPlayToEndTime(_ sender: Notification) {
        super.singleTapped()
        setPlayButton(hidden: false)
        player?.pause()
        player?.seek(to: .zero)
    }
}
