//
//  PhotoEditorViewModel.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class PhotoEditorViewModel {
    
    @Injected(\.photoOptions)
    var options: EditorPhotoOptionsInfo
    
    var image: UIImage!
    
    lazy var stack: PhotoEditingStack = {
        let stack = PhotoEditingStack(identifier: options.cacheIdentifier)
//        stack.delegate = self
        return stack
    }()
    
    /// Real image size, not image view size
    var imageSize: CGSize { image.size }
    
    // ##### View #####
    
    weak var scrollView: UIScrollView?
    
    // ##### Action #####
    
    var actionSubject = PassthroughSubject<PhotoEditorAction, Never>()
    
    // ##### Observe device properties change #####
    
    /// Container size
    var containerSize: CGSize { containerSizeSubject.value }
    var containerSizeSubject = CurrentValueSubject<CGSize, Never>(.zero)
    
    /// Safe area
    var safeAreaInsets: UIEdgeInsets { safeAreaInsetsSubject.value }
    var safeAreaInsetsSubject = CurrentValueSubject<UIEdgeInsets, Never>(.zero)
    
    /// TraitCollection
    var traitCollection: UITraitCollection { traitCollectionSubject.value }
    var traitCollectionSubject = CurrentValueSubject<UITraitCollection, Never>(.current)
    
    // ##### Helper #####
    
    var isAvailable: Bool { containerSize != .zero }
    
    var isRegular: Bool { traitCollection.horizontalSizeClass == .regular }
}

extension PhotoEditorViewModel {
    
    var isHorizontalImage: Bool {
        guard isAvailable && imageSize != .zero else { return true }
        let maxSize = containerSize
        let horizontalHeight = maxSize.width * imageSize.height / imageSize.width
        return horizontalHeight <= maxSize.height
    }
    
    var fitImageSize: CGSize {
        guard isAvailable && imageSize != .zero else { return .zero }
        #if DEBUG
//        let maxSize = CGSize(width: containerSize.width - safeAreaInsets.left - safeAreaInsets.right - 30 * 2,
//                             height: containerSize.height - safeAreaInsets.top - safeAreaInsets.bottom - 44 - 100)
        #endif
        let maxSize = containerSize
        if isHorizontalImage {
            return CGSize(width: maxSize.width, height: maxSize.width * imageSize.height / imageSize.width)
        } else {
            return CGSize(width: maxSize.height * imageSize.width / imageSize.height, height: maxSize.height)
        }
    }
    
    var centerOfContentSize: CGPoint {
        guard isAvailable && imageSize != .zero else { return .zero }
        guard let scrollView = scrollView else { return .zero }
        let contentSize = scrollView.contentSize
        let contentInset = scrollView.contentInset
        let maxSize = containerSize
        let deltaWidth = maxSize.width - contentSize.width - contentInset.left - contentInset.right
        let offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0
        let deltaHeight = maxSize.height - contentSize.height - contentInset.top - contentInset.bottom
        let offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0
        return CGPoint(x: contentSize.width * 0.5 + offsetX,
                       y: contentSize.height * 0.5 + offsetY)
    }
    
    var minimumZoomScale: CGFloat {
        return 1.0
    }
    
    var maximumZoomScale: CGFloat {
        guard isAvailable && imageSize != .zero else { return .zero }
        let maxSize = containerSize
        if isHorizontalImage {
            return (imageSize.width / maxSize.width) * 4
        } else {
            return (imageSize.height / maxSize.width) * 4
        }
    }
    
    var contentInset: UIEdgeInsets {
        guard isAvailable && imageSize != .zero else { return .zero }
        let maxSize = containerSize
        let contentSize = fitImageSize
        let rightInset = maxSize.width - contentSize.width + 0.1
        let bottomInset = maxSize.height - contentSize.height + 0.1
        return UIEdgeInsets(top: 0.1, left: 0.1, bottom: bottomInset, right: rightInset)
    }
}

extension CGFloat {
    
    var desc: String {
        String(format: "%.2lf", self)
    }
}

extension Double {
    
    var desc: String {
        String(format: "%.2lf", self)
    }
}

// MARK: - Brush
extension PhotoEditorViewModel {
    
    func send(action: PhotoEditorAction) {
        switch action {
        case .brushFinishDraw(let data):
            stack.addBrush(data)
        case .brushUndo:
            stack.brushUndo()
        default:
            break
        }
        actionSubject.send(action)
    }
}
