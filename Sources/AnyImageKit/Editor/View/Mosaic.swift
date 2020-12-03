//
//  Mosaic.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/25.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol MosaicDelegate: AnyObject {
    
    func mosaicDidBeginPen()
    func mosaicDidEndPen()
}

protocol MosaicDataSource: AnyObject {
    
    func mosaicGetLineWidth() -> CGFloat
}

/// 马赛克视图容器，马赛克实现方式采用多个马赛克叠加产生，所以最外层是一个容器，管理内部多个马赛克图层
final class Mosaic: UIView {

    weak var dataSource: MosaicDataSource?
    weak var delegate: MosaicDelegate?
    
    var didDraw: (() -> Void)?
    
    private let mosaicOptions: [EditorMosaicOption]
    private let originalMosaicImage: UIImage // 原图传统马赛克的图片
    private var mosaicImage: [UIImage] = []
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
}

// MARK: - Public
extension Mosaic {
    
    func undo(last: Int = 0) {
        guard last < contentViews.count else { return }
        let contentView = contentViews.reversed()[last]
        if !contentView.undo() {
            removeEmptyContent(removeLast: false)
            undo(last: 1)
        }
    }
    
    func setMosaicCoverImage(_ idx: Int) {
        removeEmptyContent()
        if let lastContent = contentViews.last, lastContent.idx == idx {
            return
        }
        createContentView(idx: idx)
    }
    
    func updateView(with edit: PhotoEditingStack.Edit) {
        contentViews.forEach { $0.removeFromSuperview() }
        contentViews.removeAll()
        for data in edit.mosaicData {
            let contentView = createContentView(idx: data.idx)
            contentView.setDrawn(paths: data.drawnPaths)
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
