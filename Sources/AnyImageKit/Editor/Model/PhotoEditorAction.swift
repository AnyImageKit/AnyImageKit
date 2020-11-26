//
//  PhotoEditorAction.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/26.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

enum PhotoEditorAction {
    case empty
    case back
    case done
    
    case pen
    case text
    case crop
    case mosaic
    
    case penBeginDraw
    case penUndo
    case penChangeColor(Int)
    case penFinishDraw([PenData])
    
    case mosaicBeginDraw
    case mosaicUndo
    case mosaicChangeImage(Int)
    case mosaicFinishDraw([MosaicData])
    
    case cropUpdateOption(Int)
    case cropReset
    case cropCancel
    case cropDone(CropData)
    
    case textCancel
    case textDone(TextData)
    case textUpdateData([TextData])
}
