//
//  PreviewAssetPhotoLiveCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/22.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import PhotosUI

final class PreviewAssetPhotoLiveCell: PreviewAssetContentCell {
    
    private lazy var livePhotoView: PHLivePhotoView = makeLivePhotoView()
    private lazy var livePhotoTipView: LivePhotoTipView = makeLivePhotoTipView()
    private lazy var longPress: UILongPressGestureRecognizer = makeLongPressGesture()
    
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
        livePhotoView.livePhoto = nil
    }
    
    override func optionsDidUpdate(options: PickerOptionsInfo) {
        accessibilityLabel = options.theme[string: .livePhoto]
    }
}

// MARK: PreviewAssetContent
extension PreviewAssetPhotoLiveCell {
    
    func layoutDidUpdate() {
        livePhotoView.frame = CGRect(origin: .zero, size: fitSize)
    }
    
    func loadingProgressDidUpdate(_ progress: Double) {
        livePhotoTipView.isHidden = progress != 1
    }
    
    func singleTapped() {
        sendSingleTappedEvent()
//        if let hidden = delegate?.previewCellGetToolBarHiddenState(), loadingView.isHidden {
//            livePhotoTipView.isHidden = hidden
//        }
    }
    
    func panBegin() {
        sendPanEvent(state: .begin)
        livePhotoView.isHidden = true
        livePhotoTipView.isHidden = true
    }
    
    func panEnded(_ exit: Bool) {
        sendPanEvent(state: .end(exit))
        if !exit {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25) { [weak self] in
                guard let self = self else { return }
                self.livePhotoView.isHidden = false
//                if let hidden = self.delegate?.previewCellGetToolBarHiddenState() {
//                    self.livePhotoTipView.isHidden = hidden
//                }
            }
        }
    }
    
    func setContent<Resource>(asset: Asset<Resource>) where Resource: IdentifiableResource, Resource: LoadableResource {
        task?.cancel()
        task = Task {
            do {
                try await loadLivePhoto(asset: asset)
            } catch {
                _print(error)
            }
        }
    }
    
    private func loadLivePhoto<Resource>(asset: Asset<Resource>) async throws where Resource: IdentifiableResource, Resource: LoadableResource {
        for try await result in asset.loadLivePhoto() {
            switch result {
            case .progress(let progress):
                _print("Loading Live Photo: \(progress)")
                updateLoadingProgress(progress)
            case .success(let loadResult):
                switch loadResult {
                case .thumbnail(let image):
                    setImage(image)
                case .preview(let image):
                    updateLoadingProgress(1.0)
                    setImage(image)
                default:
                    break
                }
            }
        }
    }
}

// MARK: UI Setup
extension PreviewAssetPhotoLiveCell {
    
    private func setupView() {
        scrollView.delegate = self
        
        imageView.addSubview(livePhotoView)
        contentView.addSubview(livePhotoTipView)
        
        livePhotoTipView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(100)
            maker.left.equalToSuperview().offset(10)
            maker.height.equalTo(25)
        }
        
        contentView.addGestureRecognizer(longPress)
    }
    
    private func makeLivePhotoView() -> PHLivePhotoView {
        let view = PHLivePhotoView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }
    
    private func makeLivePhotoTipView() -> LivePhotoTipView {
        let view = LivePhotoTipView(frame: .zero)
        return view
    }
    
    private func makeLongPressGesture() -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        gesture.delaysTouchesBegan = true
        gesture.minimumPressDuration = 0.3
        return gesture
    }
}

// MARK: - Action
extension PreviewAssetPhotoLiveCell {
    
    /// 长按播放 live photo
    @objc private func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard livePhotoView.livePhoto != nil else { return }
        switch gesture.state {
        case .began:
            livePhotoView.startPlayback(with: .full)
        case .ended, .cancelled:
            livePhotoView.stopPlayback()
        default:
            break
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PreviewAssetPhotoLiveCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = centerOfContentSize
    }
}
