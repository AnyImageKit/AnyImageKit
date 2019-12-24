//
//  VideoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

protocol VideoEditorControllerDelegate: class {
    
    func videoEditorDidCancel(_ editor: VideoEditorController)
    func videoEditor(_ editor: VideoEditorController, didFinishEditing video: URL, isEdited: Bool)
}

final class VideoEditorController: UIViewController {
    
    private let resource: VideoResource
    private let placeholdImage: UIImage?
    private let config: ImageEditorController.VideoConfig
    private weak var delegate: VideoEditorControllerDelegate?
    
    private var didAddPlayerObserver = false
    
    private lazy var videoPreview: VideoPreview = {
        let view = VideoPreview(frame: .zero, image: placeholdImage)
        return view
    }()
    private lazy var toolView: VideoEditorToolView = {
        let view = VideoEditorToolView(frame: .zero, config: config)
        view.cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        view.cropButton.addTarget(self, action: #selector(cropButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var cropToolView: VideoEditorCropToolView = {
        let view = VideoEditorCropToolView(frame: .zero, config: config)
        view.delegate = self
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.color(hex: 0x1F1E1F)
        return view
    }()
    
    init(resource: VideoResource, placeholdImage: UIImage?, config: ImageEditorController.VideoConfig, delegate: VideoEditorControllerDelegate) {
        self.resource = resource
        self.placeholdImage = placeholdImage
        self.config = config
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
        view.addSubview(toolView)
        view.addSubview(cropToolView)
        
        videoPreview.snp.makeConstraints { (maker) in
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                maker.top.equalToSuperview()
            }
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(cropToolView.snp.top).offset(-30)
        }
        toolView.snp.makeConstraints { (maker) in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
            maker.left.right.equalToSuperview().inset(15)
            maker.height.equalTo(45)
        }
        cropToolView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview().inset(15)
            maker.bottom.equalTo(toolView.snp.top).offset(-30)
            maker.height.equalTo(50)
        }
    }
    
    private func loadData() {
        resource.loadURL { (result) in
            switch result {
            case .success(let url):
                hideHUD()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.videoPreview.setupPlayer(url: url)
                    self.setupProgressImage(url)
                }
            case .failure(let error):
                if error == .cannotFindInLocal {
                    showWaitHUD()
                } else {
                    hideHUD()
                }
                // TODO:
                _print(error)
            }
        }
    }
}

// MARK: - Target
extension VideoEditorController {
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        delegate?.videoEditorDidCancel(self)
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func cropButtonTapped(_ sender: UIButton) {
        
    }
}

// MARK: - VideoPreviewDelegate
extension VideoEditorController: VideoPreviewDelegate {
    
    func previewPlayerDidPlayToEndTime(_ view: VideoPreview) {
        cropToolView.playButton.isSelected = view.isPlaying
    }
}

// MARK: - VideoEditorCropToolViewDelegate
extension VideoEditorController: VideoEditorCropToolViewDelegate {
    
    func cropTool(_ view: VideoEditorCropToolView, playButtonTapped button: UIButton) {
        videoPreview.playOrPause()
        button.isSelected = videoPreview.isPlaying
        addPlayerObserver()
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
    
    private func setupProgressImage(_ url: URL) {
        // TODO: 没有占位图取第一帧
        let margin: CGFloat = 15 * 2.0
        let playButtonWidth: CGFloat = 45 + 2
        let progressButtonWidth: CGFloat = 20 * 2.0
        let imageSize = placeholdImage!.size
        let itemSize = CGSize(width: imageSize.width * 40 / imageSize.height, height: 40)
        let progressWidth = view.bounds.width - margin - playButtonWidth - progressButtonWidth
        let count = Int(round(progressWidth / itemSize.width))
        
        cropToolView.progressView.setupProgressImages(count, image: placeholdImage)
        getVideoThumbnailImage(url: url, count: count) { (idx, image) in
            let scale = UIScreen.main.scale
            let resizedImage = UIImage.resize(from: image, limitSize: CGSize(width: itemSize.width * scale, height: itemSize.height * scale), isExact: true)
            DispatchQueue.main.async { [weak self] in
                self?.cropToolView.progressView.setProgressImage(resizedImage, idx: idx)
            }
        }
    }
    
    private func getVideoThumbnailImage(url: URL, count: Int, completion: @escaping (Int, UIImage) -> Void) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceAfter = .zero
            generator.requestedTimeToleranceBefore = .zero
            let seconds = asset.duration.seconds
            let array = (0..<count).map{ NSValue(time: CMTime(seconds: Double($0)*(seconds/Double(count)), preferredTimescale: 1000)) }
            var i = 0
            generator.generateCGImagesAsynchronously(forTimes: array) { (requestedTime, cgImage, actualTime, result, error) in
                i += 1
                if let image = cgImage, result == .succeeded {
                    completion(i, UIImage(cgImage: image))
                }
            }
        }
    }
    
    private func addPlayerObserver() {
        if videoPreview.player != nil && !didAddPlayerObserver {
            didAddPlayerObserver = true
            videoPreview.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: nil, using: { [weak self] (time) in
                guard let self = self else { return }
                guard self.videoPreview.isPlaying else { return }
                guard let current = self.videoPreview.player?.currentItem?.currentTime() else { return }
                guard let totle = self.videoPreview.player?.currentItem?.duration else { return }
                let progress = CGFloat(current.seconds / totle.seconds)
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
}
