//
//  PhotoEditorContentView+Mosaic.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Public function
extension PhotoEditorContentView {

    
}

// MARK: - Internal function
extension PhotoEditorContentView {
    
    /// 在子线程创建马赛克图片
    internal func setupMosaicView(completion: @escaping ((Bool) -> Void)) {
        guard mosaic == nil else { completion(false); return }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { completion(false); return }
            guard let mosaicImage = self.image.mosaicImage(level: self.options.mosaicLevel) else { completion(false); return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { completion(false); return }
                _print("Mosaic created")
                self.mosaic = Mosaic(mosaicOptions: self.options.mosaicOptions,
                                     originalMosaicImage: mosaicImage)
                self.mosaic?.delegate = self
                self.mosaic?.dataSource = self
                self.mosaic?.isUserInteractionEnabled = false
                self.imageView.insertSubview(self.mosaic!, belowSubview: self.canvas)
                self.updateCanvasFrame()
                completion(true)
            }
        }
    }
}

// MARK: - MosaicDelegate
extension PhotoEditorContentView: MosaicDelegate {
    
    func mosaicDidBeginPen() {
        context.action(.mosaicBeginDraw)
    }
    
    func mosaicDidEndPen() {
        guard let mosaic = mosaic else { return }
        context.action(.mosaicFinishDraw(mosaic.contentViews.map { MosaicData(idx: $0.idx, drawnPaths: $0.drawnPaths) }))
    }
}

// MARK: - MosaicDataSource
extension PhotoEditorContentView: MosaicDataSource {
    
    func mosaicGetLineWidth() -> CGFloat {
        let scale = scrollView.zoomScale
        return options.mosaicWidth / scale
    }
}
