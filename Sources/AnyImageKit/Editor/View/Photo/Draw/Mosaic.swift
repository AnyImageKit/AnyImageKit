//
//  Mosaic.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/25.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol MosaicDelegate: AnyObject {
    
    func mosaicDidBeginDraw()
    func mosaicDidEndDraw()
}

protocol MosaicDataSource: AnyObject {
    
    func mosaicGetLineWidth() -> CGFloat
}

/// 马赛克视图容器，马赛克实现方式采用多个马赛克叠加产生，所以最外层是一个容器，管理内部多个马赛克图层
final class Mosaic: UIView {

    weak var dataSource: MosaicDataSource? {
        didSet {
            contentViews.forEach {
                $0.dataSource = dataSource
            }
        }
    }
    weak var delegate: MosaicDelegate? {
        didSet {
            contentViews.forEach {
                $0.delegate = delegate
            }
        }
    }
    
    var didDraw: (() -> Void)?
    
    private let mosaicOptions: [EditorMosaicOption]
    private let originalMosaicImage: UIImage // 原图传统马赛克的图片
    private var originBounds: CGRect = .zero
    private(set) var mosaicImage: [UIImage] = []
    private(set) var contentViews: [MosaicContentView] = []
    
    init(mosaicOptions: [EditorMosaicOption], originalMosaicImage: UIImage) {
        self.mosaicOptions = mosaicOptions
        self.originalMosaicImage = originalMosaicImage
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        for option in mosaicOptions {
            let image: UIImage
            switch option {
            case .default:
                image = originalMosaicImage
            case .custom(_, let customMosaic):
                image = customMosaic
            }
            mosaicImage.append(image)
        }
        setMosaicCoverImage(0)
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

// MARK: - Public
extension Mosaic {
    
    func setMosaicCoverImage(_ idx: Int) {
        removeEmptyContent()
        if let lastContent = contentViews.last, lastContent.idx == idx {
            return
        }
        createContentView(idx: idx)
    }
    
    func updateView(with edit: PhotoEditingStack.Edit) {
        let lastImageIdx = contentViews.last?.idx ?? 0
        var sameIdx = 0
        for i in 0..<edit.mosaicData.count {
            if i < contentViews.count {
                if edit.mosaicData[i].idx == contentViews[i].idx && edit.mosaicData[i].drawnPaths == contentViews[i].drawnPaths {
                    sameIdx = i + 1
                } else {
                    break
                }
            }
        }
        for _ in sameIdx..<contentViews.count {
            let contentView = contentViews.removeLast()
            contentView.removeFromSuperview()
        }
        for i in sameIdx..<edit.mosaicData.count {
            let contentView = createContentView(idx: edit.mosaicData[i].idx)
            contentView.setDrawn(paths: edit.mosaicData[i].drawnPaths)
        }
        if contentViews.last?.idx != lastImageIdx {
            createContentView(idx: lastImageIdx)
        }
    }
}

// MARK: - Private
extension Mosaic {
    
    @discardableResult
    private func createContentView(idx: Int) -> MosaicContentView {
        let contentView = MosaicContentView(idx: idx, mosaic: mosaicImage[idx])
        contentView.delegate = delegate
        contentView.dataSource = dataSource
        contentView.didDraw = { [weak self] in
            self?.didDraw?()
        }
        addSubview(contentView)
        contentViews.append(contentView)
        contentView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        return contentView
    }
    
    private func removeEmptyContent(removeLast: Bool = false) {
        for (i, content) in contentViews.reversed().enumerated() {
            let idx = contentViews.count - 1 - i
            if content.drawnPaths.isEmpty {
                if i == 0 && !removeLast { continue }
                contentViews.remove(at: idx)
            }
        }
    }
}
