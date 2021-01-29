//
//  PhotoEditorCropContext.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/1.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PhotoEditorCropContext {
    
    /// 正在裁剪
    var isCrop: Bool = false
    /// 图片已经裁剪
    var didCrop: Bool = false
    /// 裁剪框的位置
    var cropRect: CGRect = .zero
    /// pan手势开始时裁剪框的位置
    var cropStartPanRect: CGRect = .zero
    /// 裁剪框与imageView真实的位置
    var cropRealRect: CGRect = .zero
    /// 裁剪尺寸
    var cropOption: EditorCropOption = .free
    /// 上次裁剪开始时图片的Bounds
    var lastImageViewBounds: CGRect = .zero
    /// 裁剪后的contentSize
    var contentSize: CGSize = .zero
    /// 裁剪后的imageViewFrame
    var imageViewFrame: CGRect = .zero
    /// 裁剪掉的高度
    var croppedHeight: CGFloat = 0
    /// 上次裁剪的数据，用于再次进入裁剪
    var lastCropData: CropData = CropData()
}
