//
//  PreviewAssetPhotoLiveCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/22.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import PhotosUI

final class PreviewAssetPhotoLiveCell: PreviewAssetCell {
    
    private lazy var livePhotoView: PHLivePhotoView = makeLivePhotoView()
    private lazy var livePhotoTipView: LivePhotoTipView = makeLivePhotoTipView()
    private lazy var longPress: UILongPressGestureRecognizer = makeLongPressGesture()
    
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
    
    
    
//    override func singleTapped() {
//        super.singleTapped()
//        if let hidden = delegate?.previewCellGetToolBarHiddenState(), loadingView.isHidden {
//            livePhotoTipView.isHidden = hidden
//        }
//    }
    
    override func panBegin() {
        super.panBegin()
        livePhotoView.isHidden = true
        livePhotoTipView.isHidden = true
    }
    
    override func panEnded(_ exit: Bool) {
        super.panEnded(exit)
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
    
    
    
    override func optionsDidUpdate(options: PickerOptionsInfo) {
        accessibilityLabel = options.theme[string: .livePhoto]
    }
    
    override func setContent(asset: Asset<PHAsset>) {
        
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

extension PreviewAssetPhotoLiveCell {
    
//    func requestLivePhoto() {
//        let id = asset.identifier
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            let options = PhotoLiveFetchOptions(targetSize: PHImageManagerMaximumSize)  { (progress, error, isAtEnd, info) in
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self, self.asset.identifier == id else { return }
//                    _print("Download live photo from iCloud: \(progress)")
//                    self.setDownloadingProgress(progress)
//                }
//            }
//            self.manager.requestPhotoLive(for: self.asset.phAsset, options: options) { result in
//                switch result {
//                case .success(let response):
//                    DispatchQueue.main.async { [weak self] in
//                        guard let self = self, self.asset.identifier == id else { return }
//                        self.livePhotoView.livePhoto = response.livePhoto
//                        self.setDownloadingProgress(1.0)
//                    }
//                case .failure(let error):
//                    _print(error.localizedDescription)
//                }
//            }
//        }
//    }
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
