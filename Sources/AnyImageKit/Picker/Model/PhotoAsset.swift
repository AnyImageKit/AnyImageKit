//
//  PhotoAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

public class PhotoAsset: Asset<PHAsset> {
    
    var _images: [ImageKey: UIImage] = [:]
    var videoDidDownload: Bool = false
    
    var state: State = .unchecked
    var selectedNum: Int = 1
}

extension PhotoAsset {
    
    /// 输出图像
    public var image: UIImage {
        return _image ?? .init()
    }
    
    var _image: UIImage? {
        return (_images[.output] ?? _images[.edited]) ?? _images[.initial]
    }
    
    var isReady: Bool {
        switch mediaType {
        case .photo, .photoGIF, .photoLive:
            return _image != nil
        case .video:
            return videoDidDownload
        }
    }
    
    var isCamera: Bool {
        return false
    }
    
    static let cameraItemIdx: Int = -1
}

// MARK: - State
extension PhotoAsset {
    
    enum State: Equatable {
        
        case unchecked
        case normal
        case selected
        case disable(AssetDisableCheckRule)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.unchecked, unchecked):
                return true
            case (.normal, normal):
                return true
            case (.selected, selected):
                return true
            case (.disable, disable):
                return true
            default:
                return false
            }
        }
    }
    
    var isUnchecked: Bool {
        return state == .unchecked
    }
    
    var isSelected: Bool {
        get {
            return state == .selected
        }
        set {
            state = newValue ? .selected : .normal
        }
    }
    
    var isDisable: Bool {
        switch state {
        case .disable(_):
            return true
        default:
            return false
        }
    }
}

// MARK: - Disable Check
extension PhotoAsset {

    func check(disable rules: [AssetDisableCheckRule]) {
        guard isUnchecked else { return }
        for rule in rules {
            if rule.isDisable(for: self) {
                state = .disable(rule)
                return
            }
        }
        state = .normal
    }
}

extension PhotoAsset {
    
    enum ImageKey: String, Hashable {
        
        case initial
        case edited
        case output
    }
}
