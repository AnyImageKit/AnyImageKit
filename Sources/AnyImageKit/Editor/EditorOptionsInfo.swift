//
//  EditorOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/9/22.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Common

/// Pen color option
public enum EditorPenColorOption: Equatable {
    
    /// Static color.
    case custom(color: UIColor)
    
    /// Dynamic color (UIColorWell).
    @available(iOS 14.0, *)
    case colorWell(color: UIColor)
}

/// Mosaic option
public enum EditorMosaicOption: Equatable {
    
    /// Default mosaic.
    /// Blurring the original image.
    case `default`
    
    /// Custom mosaic.
    ///
    /// The principle of mosaic is to superimpose a transparent mosaic image on the original image.
    /// After the user gestures slip, the sliding part is displayed.
    /// Based on that you can customize your own mosaic.
    ///
    /// icon: Image on mosaic tool bar, it will use mosaic image as icon image if icon image is nil.
    ///
    /// mosaic: Custom mosaic image.
    case custom(icon: UIImage?, mosaic: UIImage)
    
    public static var colorful: EditorMosaicOption {
        return .custom(icon: nil, mosaic: BundleHelper.image(named: "CustomMosaic", module: .editor)!)
    }
}

/// Text color
///
/// There are two display styles for each text color element.
/// One is no background color, the text color is main color.
/// The other is that the background color is main color, and the text color is sub color(usually is white).
public struct EditorTextColor: Equatable {
    
    /// Main color
    public let color: UIColor
    
    /// Sub color
    public let subColor: UIColor
}

/// Crop option
public enum EditorCropOption: Equatable {
    
    /// Free crop, there is no crop size limit.
    case free
    
    /// Limit crop size, limit the cropping width and height ratio. Eg. w:3 h:4
    case custom(w: UInt, h: UInt)
}

// MARK: - Photo

/// Photo tool option
public enum EditorPhotoToolOption: Equatable, CaseIterable {
    
    case pen
    case text
    case crop
    case mosaic
}

// MARK: - Video

/// Video tool option
public enum EditorVideoToolOption: Equatable, CaseIterable {
    
    case clip
}


// MARK: - CaseIterable
extension EditorPenColorOption: CaseIterable {
    
    public static var allCases: [EditorPenColorOption] {
        var cases: [EditorPenColorOption] = Palette.penColors.map { .custom(color: $0) }
        if #available(iOS 14.0, *) {
            cases[cases.count-1] = .colorWell(color: Palette.penColors.last!)
            return cases
        } else {
            return cases
        }
    }
}

extension EditorMosaicOption: CaseIterable {
    
    public static var allCases: [EditorMosaicOption] {
        return [.default, .colorful]
    }
}

extension EditorCropOption: CaseIterable {
    
    public static var allCases: [EditorCropOption] {
        return [.free, .custom(w: 1, h: 1), .custom(w: 3, h: 4), .custom(w: 4, h: 3), .custom(w: 9, h: 16), .custom(w: 16, h: 9)]
    }
}


// MARK: - Extension
extension EditorPenColorOption {
    
    var color: UIColor {
        switch self {
        case .custom(let color):
            return color
        case .colorWell(let color):
            return color
        }
    }
}

extension EditorCropOption {
    
    var ratioOfWidth: CGFloat {
        switch self {
        case .free:
            return 1
        case .custom(let w, let h):
            return CGFloat(w)/CGFloat(h)
        }
    }
    
    var ratioOfHeight: CGFloat {
        switch self {
        case .free:
            return 1
        case .custom(let w, let h):
            return CGFloat(h)/CGFloat(w)
        }
    }
}

extension EditorPhotoToolOption {
    
    var imageName: String {
        switch self {
        case .pen:
            return "PhotoToolPen"
        case .text:
            return "PhotoToolText"
        case .crop:
            return "PhotoToolCrop"
        case .mosaic:
            return "PhotoToolMosaic"
        }
    }
}

extension EditorPhotoToolOption: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .pen:
            return "PEN"
        case .text:
            return "INPUT_TEXT"
        case .crop:
            return "CROP"
        case .mosaic:
            return "MOSAIC"
        }
    }
}

extension EditorVideoToolOption {
    
    var imageName: String {
        switch self {
        case .clip:
            return "VideoToolVideo"
        }
    }
}

extension EditorVideoToolOption: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .clip:
            return "CROP"
        }
    }
}
