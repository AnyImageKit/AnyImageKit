//
//  PhotoLivePreviewCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/22.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
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
    
    private lazy var livePhotoTipView: LivePhotoTipView = {
        let view = LivePhotoTipView()
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
        if let hidden = delegate?.previewCellGetToolBarHiddenState(), iCloudView.isHidden {
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
    
    override func optionsDidUpdate(options: PickerOptionsInfo) {
        accessibilityLabel = options.theme[string: .livePhoto]
    }
}

extension PhotoLivePreviewCell {
    
    func requestLivePhoto() {
        let id = asset.identifier
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let options = PhotoLiveFetchOptions(targetSize: PHImageManagerMaximumSize)  { (progress, error, isAtEnd, info) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self, self.asset.identifier == id else { return }
                    _print("Download live photo from iCloud: \(progress)")
                    self.setDownloadingProgress(progress)
                }
            }
            self.manager.requestPhotoLive(for: self.asset.phAsset, options: options) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self, self.asset.identifier == id else { return }
                        self.livePhotoView.livePhoto = response.livePhoto
                        self.setDownloadingProgress(1.0)
                    }
                case .failure(let error):
                    _print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Target
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
