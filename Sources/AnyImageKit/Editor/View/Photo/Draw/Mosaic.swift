//
//  Mosaic.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/25.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

/// 马赛克视图容器，马赛克实现方式采用多个马赛克叠加产生，所以最外层是一个容器，管理内部多个马赛克图层
final class Mosaic: UIView {

    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()

    private let queue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.Mosaic")
    private var originalMosaicImage: UIImage? // 原图传统马赛克的图片
    private var originBounds: CGRect = .zero
    private lazy var lineWidth = options.mosaic.lineWidth.width
    private(set) var mosaicImage: [UIImage] = []
    private(set) var contentViews: [MosaicContentView] = []
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        clipsToBounds = true
        isUserInteractionEnabled = false
        create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if originBounds == .zero && bounds != .zero {
            originBounds = bounds
        }
        contentViews.forEach {
            $0.originBounds = originBounds
            $0.updateMask()
        }
    }
}

// MARK: - Observer
extension Mosaic {
    
    private func bindViewModel() {
        viewModel.actionSubject.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .toolOptionChanged(let option):
                self.isUserInteractionEnabled = option == .mosaic
            case .mosaicChangeImage(let idx):
                self.setMosaicCoverImage(idx: idx)
            case .mosaicChangeLineWidth(let width):
                self.lineWidth = width
                self.contentViews.forEach { $0.lineWidth = width }
            case .mosaicUndo:
                self.undo()
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Public
extension Mosaic {
    
    func updateFrame() {
        contentViews.forEach {
            $0.originBounds = originBounds
            $0.frame = bounds
            $0.updateLayerFrame()
            $0.updateMask()
        }
    }
    
    func updateView(with edit: PhotoEditingStack.Edit) {
        for (idx, data) in edit.mosaicData.enumerated() {
            let contentView = contentViews[idx]
            if contentView.uuid != data.uuid { // Just in case
                resetContentView(with: edit)
                return
            }
            let scale = frame.size.width / viewModel.imageSize.width
            contentView.setDrawn(paths: data.drawnPaths, scale: scale)
        }
    }
    
    func resetContentView(with edit: PhotoEditingStack.Edit) {
        _print(#function)
        contentViews.forEach { $0.removeFromSuperview() }
        contentViews.removeAll()
        
        for data in edit.mosaicData {
            let contentView = createContentView(idx: data.idx, uuid: data.uuid)
            let scale = frame.size.width / viewModel.imageSize.width
            contentView.setDrawn(paths: data.drawnPaths, scale: scale)
        }
    }
}

// MARK: - Private
extension Mosaic {
    
    @discardableResult
    private func createContentView(idx: Int, uuid: String = UUID().uuidString) -> MosaicContentView {
        let contentView = MosaicContentView(viewModel: viewModel, idx: idx, mosaic: mosaicImage[idx], lineWidth: lineWidth, uuid: uuid)
        addSubview(contentView)
        contentViews.append(contentView)
        contentView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        return contentView
    }
    
    private func removeEmptyContent(removeLast: Bool = false) {
        for (i, contentView) in contentViews.reversed().enumerated() {
            let idx = contentViews.count - 1 - i
            if contentView.drawnPaths.isEmpty {
                if i == 0 && !removeLast { continue }
                contentView.removeFromSuperview()
                contentViews.remove(at: idx)
            }
        }
    }
    
    private func setMosaicCoverImage(idx: Int) {
        removeEmptyContent()
        if let lastContent = contentViews.last, lastContent.idx == idx {
            return
        }
        createContentView(idx: idx)
    }
    
    private func undo() {
        guard let content = contentViews.last else { return }
        if content.drawnPaths.isEmpty {
            if contentViews.count >= 2 {
                let penultIndex = contentViews.count - 2
                let penultContent = contentViews[penultIndex]
                penultContent.undo()
                if penultContent.drawnPaths.isEmpty {
                    penultContent.removeFromSuperview()
                    contentViews.remove(at: penultIndex)
                }
            }
        } else {
            content.undo()
        }
    }
}

// MARK: - UI
extension Mosaic {
    
    private func create() {
        queue.async {
            guard let mosaicImage = self.createMosaicImage() else { return }
            DispatchQueue.main.async {
                self.originalMosaicImage = mosaicImage
                self.setupView()
                self.bindViewModel()
                self.viewModel.send(action: .mosaicDidCreate)
            }
            self.cacheMosaicImageIfNeeded(mosaicImage)
        }
    }
    
    private func cacheMosaicImageIfNeeded(_ image: UIImage) {
        guard
            !options.cacheIdentifier.isEmpty,
            let data = image.jpegData(compressionQuality: 1.0) else { return }
        let filename = options.cacheIdentifier
        queue.async {
            FileHelper.write(photoData: data, fileType: .jpeg, filename: filename)
        }
    }
    
    private func createMosaicImage() -> UIImage? {
        if !options.cacheIdentifier.isEmpty {
            if let data = FileHelper.read(fileType: .jpeg, filename: options.cacheIdentifier) {
                return UIImage(data: data)
            }
        }
        return viewModel.image.mosaicImage(level: options.mosaic.level)
    }
    
    private func setupView() {
        for style in options.mosaic.style {
            let image: UIImage
            switch style {
            case .default:
                image = originalMosaicImage!
            case .custom(_, let customMosaic):
                image = customMosaic
            }
            mosaicImage.append(image)
        }
        setMosaicCoverImage(idx: 0)
    }
}
