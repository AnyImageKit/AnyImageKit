//
//  PhotoAssetCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import Combine
import Kingfisher

final class PhotoAssetCell: UICollectionViewCell, PickerOptionsConfigurableContent {
    
    private lazy var imageView: UIImageView = makeImageView()
    private lazy var gifView: AssetGIFHintView = makeGIFView()
    private lazy var videoView: AssetVideoHintView = makeVideoView()
    
    private lazy var editedView: EditedView = {
        let view = EditedView()
        view.isHidden = true
        return view
    }()
    private lazy var selectdCoverView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    private lazy var disableCoverView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    private(set) lazy var borderView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.layer.borderWidth = 4
        return view
    }()
    private(set) lazy var selectButton: NumberCircleButton = {
        let view = NumberCircleButton(frame: .zero, style: .default)
        view.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private var task: Task<Void, Error>?
    private var cancellables: Set<AnyCancellable> = .init()
    
    let pickerContext: PickerOptionsConfigurableContext = .init()
    let selectEvent: Delegate<Void, Void> = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupDataBinding()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupDataBinding()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        selectdCoverView.isHidden = true
        gifView.isHidden = true
        videoView.isHidden = true
        editedView.isHidden = true
        disableCoverView.isHidden = true
        borderView.isHidden = true
    }
}

// MARK: PickerOptionsConfigurableContent
extension PhotoAssetCell {
    
    func update(options: PickerOptionsInfo) {
        borderView.layer.borderColor = options.theme[color: .primary].cgColor
        selectButton.isHidden = options.selectionTapAction.hideToolBar && options.selectLimit == 1
    }
}

// MARK: UI
extension PhotoAssetCell {
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectdCoverView)
        contentView.addSubview(gifView)
        contentView.addSubview(videoView)
        contentView.addSubview(editedView)
        contentView.addSubview(disableCoverView)
        contentView.addSubview(borderView)
        contentView.addSubview(selectButton)
        
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectdCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        gifView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        videoView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        editedView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        disableCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        borderView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectButton.snp.makeConstraints { maker in
            maker.top.right.equalToSuperview().inset(0)
            maker.width.height.equalTo(40)
        }
    }
    
    private func setupDataBinding() {
        sink().store(in: &cancellables)
    }
    
    private func makeImageView() -> UIImageView {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }
    
    private func makeGIFView() -> AssetGIFHintView {
        let view = AssetGIFHintView()
        view.isHidden = true
        return view
    }
    
    private func makeVideoView() -> AssetVideoHintView {
        let view = AssetVideoHintView()
        view.isHidden = true
        return view
    }
}

extension PhotoAssetCell {
    
    var displayImage: UIImage? {
        return imageView.image
    }
    
    var displayContentView: UIImageView {
        return imageView
    }
}

// MARK: - Action
extension PhotoAssetCell {
    
    @objc private func selectButtonTapped(_ sender: NumberCircleButton) {
        selectEvent.call()
    }
}

// MARK:  Content
extension PhotoAssetCell {
    
    func setContent(asset: Asset<PHAsset>, animated: Bool = false, isPreview: Bool = false) {
        task?.cancel()
        task = Task {
            do {
                let targetSize = frame.size.displaySize
                for try await result in asset.loadImage(options: .init(targetSize: targetSize)) {
                    guard !Task.isCancelled else { return }
                    switch result {
                    case .progress:
                        break
                    case .success(let loadResult):
                        switch loadResult {
                        case .thumbnail(let image):
                            self.imageView.image = image
                        case .preview(let image):
                            self.imageView.image = image
                        default:
                            break
                        }
                    }
                }
            } catch {
                _print(error)
            }
        }
        
        updateState(asset: asset, animated: animated, isPreview: isPreview)
    }
    
    func updateState(asset: Asset<PHAsset>, animated: Bool = false, isPreview: Bool = false) {
        switch asset.mediaType {
        case .photoGIF:
            gifView.isHidden = false
        case .video:
            videoView.isHidden = false
        default:
            break
        }
        
        if !isPreview {
            selectButton.setNum(asset.selectedNum, isSelected: asset.isSelected, animated: animated)
            selectdCoverView.isHidden = !asset.isSelected
            if asset.isDisabled {
                disableCoverView.isHidden = false
            } else {
                disableCoverView.isHidden = !(asset.checker.isUpToLimit && !asset.isSelected)
            }
        }
    }
}

// MARK: - Edited View
private class EditedView: UIView {

    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        return view
    }()
    
    private lazy var coverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: self.bounds.height-35, width: self.bounds.width, height: 35)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverLayer.frame = CGRect(x: 0, y: self.bounds.height-35, width: self.bounds.width, height: 35)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(coverLayer)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(6)
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension EditedView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        imageView.image = options.theme[icon: .photoEdited]
        updateChildrenConfigurable(options: options)
    }
}
