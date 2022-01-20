//
//  PhotoLibraryAssetCollection+Cover.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/20.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
 
extension PhotoLibraryAssetCollection {
    
    @MainActor
    func loadCover(targetSize: CGSize) -> AsyncThrowingStream<UIImage, Error> {
        AsyncThrowingStream { continuation in
            if let asset = fetchOrder == .asc ? lastAsset : firstAsset {
                let options = ResourceLoadOptions.library(targetSize: targetSize)
                Task {
                    for try await result in asset.loadImage(options: options) {
                        switch result {
                        case .progress:
                            break
                        case .success(let loadResult):
                            switch loadResult {
                            case .thumbnail(let image):
                                continuation.yield(image)
                            case .preview(let image):
                                continuation.yield(image)
                                continuation.finish()
                            default:
                                break
                            }
                        }
                    }
                }
            } else {
                continuation.finish()
            }
        }
    }
}
