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
    
    func setMosaicImage(_ idx: Int) {
        mosaic?.setMosaicCoverImage(idx)
//        imageView.image = mosaicCache.read(deleteMemoryStorage: false) ?? image
    }
    
    func mosaicUndo() {
        mosaic?.undo()
//        imageView.image = mosaicCache.read(deleteMemoryStorage: true) ?? image
//        mosaic?.reset()
    }
    
    func mosaicCanUndo() -> Bool {
        return true
//        return mosaicCache.hasDiskCache()
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
                self.delegate?.mosaicDidCreated()
            }
        }
    }
}

// MARK: - MosaicDelegate
extension PhotoEditorContentView: MosaicDelegate {
    
    func mosaicDidBeginPen() {
        delegate?.photoDidBeginPen()
    }
    
    func mosaicDidEndPen() {
        delegate?.photoDidEndPen()
//        canvas.isHidden = true // 不能把画笔部分截进去
//        hiddenAllTextView() // 不能把文本截进去
//        let screenshot = imageView.screenshot(image.size)
//        canvas.isHidden = false
//        restoreHiddenTextView()
//        imageView.image = screenshot
//        mosaic?.reset()
//        mosaicCache.write(screenshot)
    }
}

// MARK: - MosaicDataSource
extension PhotoEditorContentView: MosaicDataSource {
    
    func mosaicGetLineWidth() -> CGFloat {
        let scale = scrollView.zoomScale
        return options.mosaicWidth / scale
    }
}
