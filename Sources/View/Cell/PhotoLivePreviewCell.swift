//
//  PhotoLivePreviewCell.swift
//  AnyImagePicker
//
//  Created by Ray on 2019/10/22.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import PhotosUI

final class PhotoLivePreviewCell: PreviewCell {
    
    private lazy var livePhotoView: PHLivePhotoView = {
        let view = PHLivePhotoView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var longPress: UILongPressGestureRecognizer = {
        let gr = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        gr.delaysTouchesBegan = true
        gr.minimumPressDuration = 0.3
        return gr
    }()
    
    private lazy var livePhotoTipView: LivePhotoView = {
        let view = LivePhotoView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        livePhotoView.livePhoto = nil
    }
    
    override func layout() {
        super.layout()
        livePhotoView.frame = CGRect(origin: .zero, size: fitSize)
    }
    
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
    
    override func singleTapped() {
        super.singleTapped()
        if let hidden = delegate?.previewCellGetToolBarHiddenState() {
            livePhotoTipView.isHidden = hidden
        }
    }
    
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
                if let hidden = self.delegate?.previewCellGetToolBarHiddenState() {
                    self.livePhotoTipView.isHidden = hidden
                }
            }
        }
    }
    
    override func setDownloadingProgress(_ progress: Double) {
        super.setDownloadingProgress(progress)
        livePhotoTipView.isHidden = progress != 1
    }
}

extension PhotoLivePreviewCell {
    
    func requestLivePhoto() {
        let id = asset.phAsset.localIdentifier
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let options = LivePhotoFetchOptions(targetSize: PHImageManagerMaximumSize)  { (progress, error, isAtEnd, info) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    _print("Download live photo from iCloud: \(progress)")
                    self.setDownloadingProgress(progress)
                }
            }
            PhotoManager.shared.requestLivePhoto(for: self.asset.phAsset, options: options) { (result) in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if self.asset.phAsset.localIdentifier == id {
                            self.livePhotoView.livePhoto = response.livePhoto
                        }
                    }
                case .failure(let error):
                    _print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Action
extension PhotoLivePreviewCell {
    
    /// 长按播放 live photo
    @objc private func onLongPress(_ gr: UILongPressGestureRecognizer) {
        if livePhotoView.livePhoto == nil { return }
        switch gr.state {
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
extension PhotoLivePreviewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = centerOfContentSize
    }
}
