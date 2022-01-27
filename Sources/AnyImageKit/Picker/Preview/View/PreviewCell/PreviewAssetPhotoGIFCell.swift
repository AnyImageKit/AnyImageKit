//
//  PreviewAssetPhotoGIFCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Kingfisher

final class PreviewAssetPhotoGIFCell: PreviewAssetContentCell {
    
    private var task: Task<Void, Error>?
    
    override func optionsDidUpdate(options: PickerOptionsInfo) {
        accessibilityLabel = options.theme[string: .photo]
    }
}

// MARK: PreviewAssetContent
extension PreviewAssetPhotoGIFCell {
    
    var fitSize: CGSize {
        guard let image = imageView.image else { return CGSize.zero }
        let screenSize = ScreenHelper.mainBounds.size
        if image.size.width > screenSize.width {
            let width = scrollView.bounds.width
            let scale = image.size.height / image.size.width
            return CGSize(width: width, height: scale * width)
        }
        return image.size
    }
    
    var fitFrame: CGRect {
        let size = fitSize
        let x = (scrollView.bounds.width - size.width) > 0 ? (scrollView.bounds.width - size.width) * 0.5 : 0
        let y = (scrollView.bounds.height - size.height) > 0 ? (scrollView.bounds.height - size.height) * 0.5 : 0
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    func makeImageView() -> UIImageView {
        let view = AnimatedImageView(frame: .zero)
        view.contentMode = .scaleToFill
        return view
    }
    
    func setContent<Resource>(asset: Asset<Resource>) where Resource: IdentifiableResource, Resource: LoadableResource {
        task?.cancel()
        task = Task {
            do {
                try await loadGIF(asset: asset)
            } catch {
                _print(error)
            }
        }
    }
    
    private func loadGIF<Resource>(asset: Asset<Resource>) async throws where Resource: IdentifiableResource, Resource: LoadableResource {
        for try await result in asset.loadImage() {
            switch result {
            case .progress(let progress):
                _print("Loading GIF: \(progress)")
                updateLoadingProgress(progress)
            case .success(let loadResult):
                switch loadResult {
                case .thumbnail(let image):
                    setImage(image)
                case .preview(let image):
                    updateLoadingProgress(1.0)
                    setImage(image)
                default:
                    break
                }
            }
        }
    }
}
