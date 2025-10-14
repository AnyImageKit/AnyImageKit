//
//  BrowserPreviewController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/10.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

open class BrowserPreviewController: AnyImageViewController, BrowserChildController, BrowserOptionsConfigurable {
    
    let needSyncLayoutGuideEvent = Delegate<Void, Void>()
    
    public lazy var previewView: BrowserPreviewView = {
        let view = BrowserPreviewView(contentSafeAreaLayoutGuide)
        return view
    }()
    
    var contentView: UIView { previewView.imageView }
    
    public private(set) var options: BrowserOptionsInfo
    
    private let contentSafeAreaLayoutGuide = UILayoutGuide()
    private var guideTopConstraint: NSLayoutConstraint!
    private var guideBottomConstraint: NSLayoutConstraint!
    private var guideLeadingConstraint: NSLayoutConstraint!
    private var guideTrailingConstraint: NSLayoutConstraint!
    
    required public init(options: BrowserOptionsInfo) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        update(options: options)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        needSyncLayoutGuideEvent.call()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let previewView = previewView as? BrowserVideoPreviewView {
            previewView.playWhenViewAppear()
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        previewView.scrollView.setZoomScale(previewView.scrollView.minimumZoomScale, animated: false)
        if let previewView = previewView as? BrowserVideoPreviewView {
            if previewView.isPlaying {
                previewView.playPauseButtonTapped()
                previewView.playerLayer?.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
            }
        }
    }
    
    // MARK: - Override Methods
    
    /// Configures the controller with a resource model.
    open func config(_ model: any BrowserResource) {
        previewView = createPreview(with: getMediaType(resource: model))
        
        view.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        previewView.config(model)
        previewView.update(options: options)
    }
    
    /// Hides or shows the toolbar.
    open func hideToolBar(isHidden: Bool, isAnimated: Bool = true) {
        previewView.hideToolBar(isHidden: isHidden, isAnimated: isAnimated)
    }
    
    open func createPreview(with mediaType: MediaType) -> BrowserPreviewView {
        switch mediaType {
        case .photo:
            return BrowserPhotoPreviewView(contentSafeAreaLayoutGuide)
        case .video:
            return BrowserVideoPreviewView(contentSafeAreaLayoutGuide)
        case .photoGIF:
            return BrowserGifPreviewView(contentSafeAreaLayoutGuide)
        case .photoLive:
            return BrowserLivePreviewView(contentSafeAreaLayoutGuide)
        }
    }
    
    open func getMediaType(resource: any BrowserResource) -> MediaType {
        if let asset = resource as? PHAsset {
            switch asset.mediaType {
            case .image:
                if options.supportType.contains(.photoLive) && asset.isLivePhoto {
                    return .photoLive
                } else if options.supportType.contains(.photoGIF) && asset.isGIF {
                    return .photoGIF
                }
            case .video:
                if options.supportType.contains(.video) {
                    return .video
                }
            default:
                break
            }
        }
        return .photo
    }
    
}

// MARK: - UI
extension BrowserPreviewController {
    
    private func setupView() {
        view.addLayoutGuide(contentSafeAreaLayoutGuide)
        
        guideTopConstraint = contentSafeAreaLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor)
        guideBottomConstraint = contentSafeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        guideLeadingConstraint = contentSafeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        guideTrailingConstraint = contentSafeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([
            guideTopConstraint,
            guideBottomConstraint,
            guideLeadingConstraint,
            guideTrailingConstraint
        ])
    }
    
    internal func updateSafeArea(insets: UIEdgeInsets, isAnimated: Bool) {
        let animation = {
            self.guideTopConstraint.constant = insets.top
            self.guideBottomConstraint.constant = -insets.bottom
            self.guideLeadingConstraint.constant = insets.left
            self.guideTrailingConstraint.constant = -insets.right
            self.view.layoutIfNeeded()
        }
        if isAnimated {
            UIView.animate(withDuration: 0.25, animations: animation)
        } else {
            animation()
        }
    }
}
