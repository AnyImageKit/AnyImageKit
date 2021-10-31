//
//  PhotoEditorAction.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/26.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
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
    case cropRotateToLeft
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
