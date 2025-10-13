//
//  BrowserLivePreviewView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/13.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import PhotosUI

open class BrowserLivePreviewView: BrowserPreviewView {
    
    private lazy var livePhotoView: PHLivePhotoView = {
        let view = PHLivePhotoView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var livePhotoTipView: LivePhotoTipView = {
        let view = LivePhotoTipView()
        view.isHidden = true
        return view
    }()
    
    private lazy var longPress: UILongPressGestureRecognizer = {
        let gr = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        gr.delaysTouchesBegan = true
        gr.minimumPressDuration = 0.3
        return gr
    }()
    
    override init(_ contentSafeAreaLayoutGuide: UILayoutGuide) {
        super.init(contentSafeAreaLayoutGuide)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        imageView.addSubview(livePhotoView)
        addSubview(livePhotoTipView)
        addGestureRecognizer(longPress)
    }
    
    open override func setupLayout() {
        super.setupLayout()
        livePhotoTipView.snp.makeConstraints { maker in
            maker.top.equalTo(contentSafeAreaLayoutGuide).offset(16)
            maker.left.equalTo(contentSafeAreaLayoutGuide).offset(8)
            maker.height.equalTo(25)
        }
    }
    
    open override func layout() {
        super.layout()
        livePhotoView.frame = CGRect(origin: .zero, size: fitSize)
    }
    
    open override func hideToolBar(isHidden: Bool, isAnimated: Bool = true) {
        let animation = {
            self.iCloudView.alpha = isHidden ? 0 : 1
            self.livePhotoTipView.alpha = isHidden ? 0 : 1
            self.layoutIfNeeded()
        }
        if isAnimated {
            UIView.animate(withDuration: 0.25, animations: animation)
        } else {
            animation()
        }
    }
    
    open override func config(_ model: any BrowserResource) {
        super.config(model)
        if let asset = model as? PHAsset {
            let options = PhotoLiveFetchOptions(targetSize: PHImageManagerMaximumSize)  { (progress, error, isAtEnd, info) in
                DispatchQueue.main.async {
                    _print("Download live photo from iCloud: \(progress)")
                    self.setDownloadingProgress(progress)
                }
            }
            ExportTool.requestPhotoLive(for: asset, options: options) { (result, requestID) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self.livePhotoView.livePhoto = response.livePhoto
                        self.livePhotoTipView.isHidden = false
                        self.setDownloadingProgress(1.0)
                    case .failure(let error):
                        _print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
}

// MARK: - Target
extension BrowserLivePreviewView {
    
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
