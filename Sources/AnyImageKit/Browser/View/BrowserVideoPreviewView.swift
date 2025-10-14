//
//  BrowserVideoPreviewView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/11.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
import Combine

open class BrowserVideoPreviewView: BrowserPreviewView {
    
    public var isPlaying: Bool {
        return player?.rate != 0
    }
    
    public private(set)  var player: AVPlayer?
    public private(set)  var playerLayer: AVPlayerLayer?
    
    public private(set) lazy var playPauseButton: UIButton = createButton(image: options.theme[icon: .playButton])
    public private(set) lazy var muteUnmuteButton: UIButton = createButton(image: options.theme[icon: .muteButton])
    
    public private(set) lazy var currentTimeLabel: UILabel = createTimeLabel(textAlignment: .left)
    public private(set) lazy var remainingTimeLabel: UILabel = createTimeLabel(textAlignment: .right)
    
    public private(set) lazy var progress: ElasticVideoProgressView = {
        let view = ElasticVideoProgressView(frame: .zero)
        view.trackColor = .gray
        view.progressColor = .white
        view.onPanBegan = { [weak self] in self?.handlePanBegan() }
        view.onValueChanged = { [weak self] value in self?.handleProgressChanged(value) }
        view.onDragEnd = { [weak self] value in self?.handleDragEnded(value) }
        addShadow(with: view)
        return view
    }()
    
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var dragEndSubject = PassthroughSubject<Void, Never>()
    
    private var isDraggingProgress = false
    private var playWhenLoaded = false
    
    override init(_ contentSafeAreaLayoutGuide: UILayoutGuide) {
        super.init(contentSafeAreaLayoutGuide)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - override
    
    open override func viewDidAppear() {
        super.viewDidAppear()
        playWhenViewAppear()
    }
    
    open override func viewDidDisappear() {
        super.viewDidDisappear()
        if isPlaying {
            playPauseButtonTapped()
            playerLayer?.player?.seek(to: .zero)
        }
    }
    
    open override func config(_ model: any BrowserResource) {
        super.config(model)
        if let asset = model as? PHAsset {
            let options = VideoFetchOptions(isNetworkAccessAllowed: true) { (progress, error, isAtEnd, info) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    _print("Download video from iCloud: \(progress)")
                    self.setDownloadingProgress(progress)
                }
            }
            ExportTool.requestVideo(for: asset, options: options) { (result, requestID) in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.setPlayerItem(response.playerItem)
                        self.setDownloadingProgress(1.0)
                        if self.playWhenLoaded {
                            self.player?.play()
                            self.playWhenLoaded = false
                        }
                    }
                case .failure(let error):
                    _print(error)
                }
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = imageView.bounds
    }
    
    open override func hideToolBar(isHidden: Bool, isAnimated: Bool = true) {
        let animation = {
            self.iCloudView.alpha = isHidden ? 0 : 1
            self.progress.alpha = isHidden ? 0 : 1
            self.playPauseButton.alpha = isHidden ? 0 : 1
            self.muteUnmuteButton.alpha = isHidden ? 0 : 1
            self.currentTimeLabel.alpha = 0
            self.remainingTimeLabel.alpha = 0
            self.layoutIfNeeded()
        }
        if isAnimated {
            UIView.animate(withDuration: 0.25, animations: animation)
        } else {
            animation()
        }
    }
    
    // MARK: - Public
    
    public func setPlayerItem(_ item: AVPlayerItem) {
        cancellables.forEach { $0.cancel() }
        cancellables = Set<AnyCancellable>()
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.player?.seek(to: .zero)
        if let playerLayer = playerLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            CATransaction.setAnimationDuration(0)
            imageView.layer.addSublayer(playerLayer)
            playerLayer.frame = imageView.bounds
            CATransaction.commit()
            playerLayer.actions = [
                "bounds": NSNull(),
                "position": NSNull(),
                "contents": NSNull()
            ]
        }
        addObservers()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        addSubview(progress)
        addSubview(playPauseButton)
        addSubview(muteUnmuteButton)
        addSubview(currentTimeLabel)
        addSubview(remainingTimeLabel)
        
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        muteUnmuteButton.addTarget(self, action: #selector(muteUnmuteButtonTapped), for: .touchUpInside)
        
        playPauseButton.layer.masksToBounds = false
        muteUnmuteButton.layer.masksToBounds = false
        currentTimeLabel.layer.masksToBounds = false
        remainingTimeLabel.layer.masksToBounds = false
        progress.layer.masksToBounds = false
        
        updateControls(isDragging: false, animated: false)
        
        dragEndSubject
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                if !self.isDraggingProgress {
                    self.updateControls(isDragging: false)
                }
            }
            .store(in: &cancellables)
    }

    open override func setupLayout() {
        super.setupLayout()
        progress.snp.makeConstraints { make in
            make.left.right.equalTo(contentSafeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(contentSafeAreaLayoutGuide).offset(-10)
            make.height.equalTo(30)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.left.equalTo(progress).offset(-8)
            make.bottom.equalTo(progress.snp.top)
            make.width.height.equalTo(35)
        }
        
        muteUnmuteButton.snp.makeConstraints { make in
            make.right.equalTo(progress).offset(8)
            make.bottom.equalTo(progress.snp.top)
            make.width.height.equalTo(35)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(progress)
            make.centerY.equalTo(playPauseButton)
        }
        
        remainingTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(progress)
            make.centerY.equalTo(playPauseButton)
        }
    }
    
    private func playWhenViewAppear() {
        if let player {
            player.play()
        } else {
            playWhenLoaded = true
        }
    }
    
    // MARK: - Observers
    
    private func addObservers() {
        guard let player = player else { return }
        
        // 监听播放状态
        player.publisher(for: \.rate)
            .sink { [weak self] rate in
                self?.updatePlayButton(isPlaying: rate > 0)
            }
            .store(in: &cancellables)
        
        // 监听播放时间
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self, let duration = self.player?.currentItem?.duration, !self.isDraggingProgress else { return }
            let progressValue = CGFloat(time.seconds / duration.seconds)
            self.progress.value = progressValue
        }
        
        // 监听加载状态
        player.currentItem?.publisher(for: \.duration)
            .sink(receiveValue: { [weak self] duration in
                guard let self = self else { return }
                self.currentTimeLabel.text = self.formatTime(for: 0)
                self.remainingTimeLabel.text = self.formatTime(for: duration.seconds)
            })
            .store(in: &cancellables)

        // 监听播放到结尾
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            .sink { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.updatePlayButton(isPlaying: false)
            }
            .store(in: &cancellables)
    }
    
    private func removeObservers() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    // MARK: - Actions & Handlers
    
    @objc func playPauseButtonTapped() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        let image = isPlaying ? options.theme[icon: .pauseButton] : options.theme[icon: .playButton]
        playPauseButton.setImage(image, for: .normal)
    }
    
    @objc private func muteUnmuteButtonTapped() {
        guard let player = player else { return }
        player.isMuted.toggle()
        let image = player.isMuted ? options.theme[icon: .unmuteButton] : options.theme[icon: .muteButton]
        muteUnmuteButton.setImage(image, for: .normal)
    }
    
    private func handlePanBegan() {
        isDraggingProgress = true
        player?.pause()
        updateControls(isDragging: true)
    }
    
    private func handleProgressChanged(_ value: CGFloat) {
        guard isDraggingProgress, let duration = player?.currentItem?.duration.seconds else { return }
        let currentTime = duration * Double(value)
        let remainingTime = duration - currentTime
        
        currentTimeLabel.text = formatTime(for: currentTime)
        remainingTimeLabel.text = formatTime(for: remainingTime)
        
        if let duration = player?.currentItem?.duration.seconds {
            let seekTime = CMTime(seconds: Double(value) * duration, preferredTimescale: 600)
            player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    
    private func handleDragEnded(_ value: CGFloat) {
        isDraggingProgress = false
        let seekTime = CMTime(seconds: Double(value) * (player?.currentItem?.duration.seconds ?? 0), preferredTimescale: 600)
        player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
        dragEndSubject.send()
    }
    
    // MARK: - Helpers
    
    private func updateControls(isDragging: Bool, animated: Bool = true) {
        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration) {
            self.playPauseButton.alpha = isDragging ? 0 : 1
            self.muteUnmuteButton.alpha = isDragging ? 0 : 1
            self.currentTimeLabel.alpha = isDragging ? 1 : 0
            self.remainingTimeLabel.alpha = isDragging ? 1 : 0
        }
    }
    
    private func updatePlayButton(isPlaying: Bool) {
        let image = isPlaying ? options.theme[icon: .pauseButton] : options.theme[icon: .playButton]
        playPauseButton.setImage(image, for: .normal)
    }
    
    private func formatTime(for seconds: Double) -> String {
        guard !seconds.isNaN, !seconds.isInfinite else { return "00:00:00" }
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    private func createButton(image: UIImage?) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        addShadow(with: button)
        return button
    }
    
    private func createTimeLabel(textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = textAlignment
        label.text = "00:00:00"
        addShadow(with: label)
        return label
    }
    
    private func addShadow(with view: UIView) {
        view.layer.masksToBounds = false
        view.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 8, spread: 0)
    }
}
