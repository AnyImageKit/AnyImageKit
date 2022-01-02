//
//  PhotoEditorAction.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/26.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

enum PhotoEditorAction {
    case empty
    case back
    case done
    case toolOptionChanged(EditorPhotoToolOption?)
    
    case brushBeginDraw
    case brushUndo
    case brushChangeColor(UIColor)
    case brushFinishDraw([BrushData])
    
    case mosaicBeginDraw
    case mosaicUndo
    case mosaicChangeImage(Int)
    case mosaicFinishDraw([MosaicData])
    
    case cropUpdateOption(EditorCropOption)
    case cropRotate
    case cropReset
    case cropCancel
    case cropDone
    case cropFinish(CropData)
    
    case textWillBeginEdit(TextData)
    case textBringToFront(TextData)
    case textWillBeginMove(TextData)
    case textDidFinishMove(data: TextData, delete: Bool)
    case textCancel
    case textDone(TextData)
}

extension PhotoEditorAction {
    
    var duration: TimeInterval {
        switch self {
        case .toolOptionChanged(let option):
            if let option = option, option == .crop {
                return 0.5
            }
            return 0.1
        case .cropUpdateOption, .cropReset:
            return 0.55
        case .cropRotate:
            return 0.3
        case .cropDone, .cropCancel:
            return 0.25
        default:
            return 0.0
        }
    }
}
