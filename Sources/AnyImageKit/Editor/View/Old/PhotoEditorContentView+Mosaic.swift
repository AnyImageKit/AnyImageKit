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
    

    
    func mosaicUpdateView(with edit: PhotoEditingStack.Edit) {
        
//        canvas.drawnPaths = edit.penData.map { $0.drawnPath }
//        canvas.setNeedsDisplay()
    }
}

// MARK: - Internal function
extension PhotoEditorContentView {
    
    /// 在子线程创建马赛克图片
    internal func setupMosaicView() {
        guard mosaic == nil else { return }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let mosaicImage = self.image.mosaicImage(level: self.options.mosaicLevel) else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                _print("Mosaic created")
                self.mosaic = Mosaic(mosaicOptions: self.options.mosaicOptions,
                                     originalMosaicImage: mosaicImage)
                self.mosaic?.delegate = self
                self.mosaic?.dataSource = self
                self.mosaic?.isUserInteractionEnabled = false
                self.imageView.insertSubview(self.mosaic!, belowSubview: self.canvas)
                self.updateCanvasFrame()
                self.mosaicDidCreated()
            }
        }
    }
    
    /// 马赛克图层创建完成
    private func mosaicDidCreated() {
        hideHUD()
        guard let option = context.toolOption else { return }
        if option == .mosaic {
            mosaic?.isUserInteractionEnabled = true
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
