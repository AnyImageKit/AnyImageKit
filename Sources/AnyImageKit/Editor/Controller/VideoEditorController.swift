//
//  VideoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/18.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

protocol VideoEditorControllerDelegate: AnyObject {
    
    func videoEditorDidCancel(_ editor: VideoEditorController)
    func videoEditor(_ editor: VideoEditorController, didFinishEditing video: URL, isEdited: Bool)
}

final class VideoEditorController: AnyImageViewController {
    
    private let resource: EditorVideoResource
    private let placeholderImage: UIImage?
    private let options: EditorVideoOptionsInfo
    private weak var delegate: VideoEditorControllerDelegate?
    
    private var url: URL?
    private var didAddPlayerObserver = false
    
    private lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.setImage(options.theme[icon: .returnBackButton], for: .normal)
        view.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = options.theme[string: .back]
        return view
    }()
    private lazy var videoPreview: VideoPreview = {
        let view = VideoPreview(frame: .zero, image: placeholderImage)
        view.delegate = self
        return view
    }()
    private lazy var toolView: VideoEditorToolView = {
        let view = VideoEditorToolView(frame: .zero, options: options)
        view.delegate = self
        view.isHidden = true
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var cropToolView: VideoEditorCropToolView = {
        let view = VideoEditorCropToolView(frame: .zero, options: options)
        view.delegate = self
        view.isHidden = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.color(hex: 0x1F1E1F)
        return view
    }()
    
    init(resource: EditorVideoResource, placeholderImage: UIImage?, options: EditorVideoOptionsInfo, delegate: VideoEditorControllerDelegate) {
        self.resource = resource
        self.placeholderImage = placeholderImage
        self.options = options
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupView() {
        view.backgroundColor = .black
        view.addSubview(videoPreview)
        view.addSubview(backButton)
        view.addSubview(toolView)
        view.addSubview(cropToolView)
        
        videoPreview.snp.makeConstraints { maker in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                maker.top.equalToSuperview()
            }
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(cropToolView.snp.top).offset(-30)
        }
        backButton.snp.makeConstraints { maker in
            if #available(iOS 11.0, *) {
                let topOffset = ScreenHelper.statusBarFrame.height <= 20 ? 20 : 10
                maker.top.equalTo(view.safeAreaLayoutGuide).offset(topOffset)
            } else {
                maker.top.equalToSuperview().offset(30)
            }
            maker.left.equalToSuperview().offset(10)
            maker.width.height.equalTo(50)
        }
        toolView.snp.makeConstraints { maker in
            if #available(iOS 11.0, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
            maker.left.right.equalToSuperview().inset(15)
            maker.height.equalTo(45)
        }
        cropToolView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview().inset(15)
            maker.bottom.equalTo(toolView.snp.top).offset(-30)
            maker.height.equalTo(50)
        }
        
        options.theme.buttonConfiguration[.back]?.configuration(backButton)
    }
    
    private func loadData() {
        resource.loadURL { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                self.view.hud.hide()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.url = url
                    self.toolView.isHidden = false
                    if self.toolView.selectOption(.clip) {
                        self.cropToolView.isHidden = false
                    }
                    self.getProgressImage(url: url) { [weak self] (image) in
                        self?.videoPreview.setThumbnail(image)
                        self?.videoPreview.setupPlayer(url: url)
                        self?.setupProgressImage(url: url, image: image)
                    }
                }
            case .failure(let error):
                if error == .cannotFindInLocal {
                    self.view.hud.show()
                    return
                }
                _print("Fetch URL failed: \(error.localizedDescription)")
                self.delegate?.videoEditorDidCancel(self)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Target
extension VideoEditorController {
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        delegate?.videoEditorDidCancel(self)
        trackObserver?.track(event: .editorBack, userInfo: [.page: AnyImagePage.editorVideo])
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        guard let url = url else { return }
        let start = cropToolView.progressView.left
        let end = cropToolView.progressView.right
        let isEdited = end - start != 1
        if let url = resource as? URL, !isEdited {
            _print("Export video at \(url)")
            delegate?.videoEditor(self, didFinishEditing: url, isEdited: isEdited)
            trackObserver?.track(event: .editorDone, userInfo: [.page: AnyImagePage.editorVideo])
            return
        }
        clipVideo(url: url, start: start, end: end) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                _print("Export video at \(url)")
                self.delegate?.videoEditor(self, didFinishEditing: url, isEdited: isEdited)
                self.trackObserver?.track(event: .editorDone, userInfo: [.page: AnyImagePage.editorVideo])
            case .failure(let error):
                _print(error.localizedDescription)
            }
        }
    }
}

// MARK: - VideoPreviewDelegate
extension VideoEditorController: VideoPreviewDelegate {
    
    func previewPlayerDidPlayToEndTime(_ view: VideoPreview) {
        cropToolView.playButton.isSelected = view.isPlaying
        view.setProgress(cropToolView.progressView.left)
    }
}

// MARK: - VideoEditorToolViewDelegate
extension VideoEditorController: VideoEditorToolViewDelegate {
    
    func videoEditorTool(_ tool: VideoEditorToolView, optionDidChange option: EditorVideoToolOption?) {
        guard let option = option else {
            cropToolView.isHidden = true
            return
        }
        cropToolView.isHidden = option != .clip
    }
}

// MARK: - VideoEditorCropToolViewDelegate
extension VideoEditorController: VideoEditorCropToolViewDelegate {
    
    func cropTool(_ view: VideoEditorCropToolView, playButtonTapped button: UIButton) {
        videoPreview.playOrPause()
        button.isSelected = videoPreview.isPlaying
        addPlayerObserver()
        trackObserver?.track(event: .editorVideoPlayPause, userInfo: [.isOn: videoPreview.isPlaying])
    }
    
    func cropTool(_ view: VideoEditorCropToolView, didUpdate progress: CGFloat) {
        if videoPreview.isPlaying {
            videoPreview.playOrPause()
            view.playButton.isSelected = videoPreview.isPlaying
        }
        videoPreview.setProgress(progress)
    }
    
    func cropToolDurationOfVideo(_ view: VideoEditorCropToolView) -> CGFloat {
        return CGFloat(videoPreview.player?.currentItem?.duration.seconds ?? 0)
    }
}

// MARK: - Private
extension VideoEditorController {
    
    /// 获取进度条上第一张缩略图
    private func getProgressImage(url: URL, completion: @escaping (UIImage) -> Void) {
        if let image = placeholderImage {
            completion(image)
            return
        }
        getVideoThumbnailImage(url: url, count: 1) { (_, image) in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    /// 设置进度条上的缩略图
    private func setupProgressImage(url: URL, image: UIImage) {
        let margin: CGFloat = 15 * 2.0
        let playButtonWidth: CGFloat = 45 + 2
        let progressButtonWidth: CGFloat = 20 * 2.0
        let imageSize = image.size
        let itemSize = CGSize(width: imageSize.width * 40 / imageSize.height, height: 40)
        let progressWidth = view.bounds.width - margin - playButtonWidth - progressButtonWidth
        let count = Int(round(progressWidth / itemSize.width))
        
        cropToolView.progressView.setupProgressImages(count, image: image)
        getVideoThumbnailImage(url: url, count: count) { (idx, image) in
            let scale = UIScreen.main.scale
            let resizedImage = UIImage.resize(from: image, limitSize: CGSize(width: itemSize.width * scale, height: itemSize.height * scale), isExact: true)
            DispatchQueue.main.async { [weak self] in
                self?.cropToolView.progressView.setProgressImage(resizedImage, idx: idx)
            }
        }
    }
    
    /// 获取缩略图
    private func getVideoThumbnailImage(url: URL, count: Int, completion: @escaping (Int, UIImage) -> Void) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceAfter = .zero
            generator.requestedTimeToleranceBefore = .zero
            let seconds = asset.duration.seconds
            let array = (1...count).map{ NSValue(time: CMTime(seconds: Double($0)*(seconds/Double(count)), preferredTimescale: 1000)) }
            var i = 0
            generator.generateCGImagesAsynchronously(forTimes: array) { (requestedTime, cgImage, actualTime, result, error) in
                i += 1
                if let image = cgImage, result == .succeeded {
                    completion(i, UIImage(cgImage: image))
                }
            }
        }
    }
    
    /// 监听播放过程，实时更新进度条
    private func addPlayerObserver() {
        if videoPreview.player != nil && !didAddPlayerObserver {
            didAddPlayerObserver = true
            videoPreview.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: nil, using: { [weak self] (time) in
                guard let self = self else { return }
                guard self.videoPreview.isPlaying else { return }
                guard let current = self.videoPreview.player?.currentItem?.currentTime() else { return }
                guard let total = self.videoPreview.player?.currentItem?.duration else { return }
                let progress = CGFloat(current.seconds / total.seconds)
                let progressView = self.cropToolView.progressView
                self.cropToolView.progressView.setProgress(progress)
                if progress >= progressView.right {
                    self.videoPreview.player?.pause()
                    self.cropToolView.playButton.isSelected = self.videoPreview.isPlaying
                    self.cropToolView.progressView.setProgress(self.cropToolView.progressView.left)
                    self.videoPreview.setProgress(self.cropToolView.progressView.left)
                }
            })
        }
    }
    
    /// 剪辑视频
    private func clipVideo(url: URL, start: CGFloat, end: CGFloat, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let duration = videoPreview.player?.currentItem?.duration else { return }
        let asset = AVURLAsset(url: url)
        let startTime = CMTime(seconds: duration.seconds * Double(start), preferredTimescale: duration.timescale)
        let captureDuration = CMTime(seconds: duration.seconds * Double(end - start), preferredTimescale: duration.timescale)
        let timeRange = CMTimeRange(start: startTime, duration: captureDuration)
        
        let composition = AVMutableComposition()
        let videoComposition = addVideoComposition(composition, timeRange: timeRange, asset: asset)
        addAudioComposition(composition, timeRange: timeRange, asset: asset)
        exportVideo(composition, videoComposition: videoComposition, metadata: asset.metadata, completion: completion)
    }
    
    /// 增加视频轨道
    private func addVideoComposition(_ composition: AVMutableComposition, timeRange: CMTimeRange, asset: AVURLAsset) -> AVVideoComposition? {
        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return nil
        }
        guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else {
            return nil
        }
        do {
            try compositionTrack.insertTimeRange(timeRange, of: assetVideoTrack, at: .zero)
        } catch {
            _print(error)
            return nil
        }
        compositionTrack.preferredTransform = assetVideoTrack.preferredTransform
        
        let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
        videolayerInstruction.setOpacity(0.0, at: asset.duration)
        
        let videoCompositionInstrution = AVMutableVideoCompositionInstruction()
        videoCompositionInstrution.timeRange = CMTimeRange(start: .zero, duration: compositionTrack.asset!.duration)
        videoCompositionInstrution.layerInstructions = [videolayerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = compositionTrack.naturalSize
        videoComposition.frameDuration = CMTime(seconds: 1, preferredTimescale: 30)
        videoComposition.instructions = [videoCompositionInstrution]
        return videoComposition
    }
    
    /// 增加音频轨道
    private func addAudioComposition(_ composition: AVMutableComposition, timeRange: CMTimeRange, asset: AVURLAsset) {
        let audioAssetTracks = asset.tracks(withMediaType: .audio)
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        for track in audioAssetTracks {
            do {
                try audioTrack.insertTimeRange(timeRange, of: track, at: .zero)
            } catch {
                _print(error)
            }
        }
    }
    
    /// 导出视频
    private func exportVideo(_ composition: AVMutableComposition, videoComposition: AVVideoComposition?, metadata: [AVMetadataItem], completion: @escaping (Result<URL, Error>) -> Void) {
        let tmpPath = FileHelper.temporaryDirectory(for: .video)
        let dateString = FileHelper.dateString()
        let filePath = tmpPath.appending("Video-\(dateString).mp4")
        FileHelper.createDirectory(at: tmpPath)
        let outputURL = URL(fileURLWithPath: filePath)
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) else { return }
        exportSession.metadata = metadata
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        if videoComposition != nil {
            exportSession.videoComposition = videoComposition
        }
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if let error = exportSession.error {
                    completion(.failure(error))
                } else {
                    completion(.success(outputURL))
                }
            }
        }
    }
}
