//
//  PhotoEditorContentView+Mosaic.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - Internal function
extension PhotoEditorContentView {
    
    /// 在子线程创建马赛克图片
    internal func setupMosaicView(completion: @escaping ((Bool) -> Void)) {
        guard mosaic == nil else { completion(false); return }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { completion(false); return }
            guard let mosaicImage = self.createMosaicImage() else { completion(false); return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { completion(false); return }
                _print("Mosaic created")
                self.mosaic = Mosaic(mosaicOptions: self.options.mosaicOptions,
                                     originalMosaicImage: mosaicImage)
                self.mosaic?.delegate = self
                self.mosaic?.dataSource = self
                self.mosaic?.isUserInteractionEnabled = false
                self.imageView.insertSubview(self.mosaic!, belowSubview: self.canvas)
                self.updateSubviewFrame()
                completion(true)
                self.cacheMosaicImageIfNeeded(mosaicImage)
            }
        }
    }
    
    private func cacheMosaicImageIfNeeded(_ image: UIImage) {
        guard
            !options.cacheIdentifier.isEmpty,
            let data = image.jpegData(compressionQuality: 1.0) else { return }
        let filename = options.cacheIdentifier
        let queue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.CacheMosaicImage")
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
        return image.mosaicImage(level: options.mosaicLevel)
    }
}

// MARK: - MosaicDelegate
extension PhotoEditorContentView: MosaicDelegate {
    
    func mosaicDidBeginDraw() {
        context.action(.mosaicBeginDraw)
    }
    
    func mosaicDidEndDraw() {
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
