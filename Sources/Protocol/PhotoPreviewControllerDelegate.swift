//
//  PhotoPreviewControllerDelegate.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

protocol PhotoPreviewControllerDataSource: class {
    
    typealias PreviewData = (thumbnail: UIImage?, asset: Asset)
    
    /// 获取需要展示图片的数量
    func numberOfPhotos(in controller: PhotoPreviewController) -> Int
    
    /// 获取索引对应的数据模型
    func previewController(_ controller: PhotoPreviewController, assetOfIndex index: Int) -> PreviewData
    
    /// 获取转场动画时的缩略图所在的 view
    func previewController(_ controller: PhotoPreviewController, thumbnailViewForIndex index: Int) -> UIView?
}

protocol PhotoPreviewControllerDelegate: class {
    
    /// 选择一张图片，需要返回所选图片的序号
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int)
    
    /// 取消选择一张图片
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int)
    
    /// 开启/关闭原图
    func previewController(_ controller: PhotoPreviewController, useOriginalPhoto: Bool)
    
    /// 点击返回
    func previewControllerDidClickBack(_ controller: PhotoPreviewController)
    
    /// 点击完成
    func previewControllerDidClickDone(_ controller: PhotoPreviewController)
}

extension PhotoPreviewControllerDelegate {
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int) { }
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int) { }
    func previewController(_ controller: PhotoPreviewController, useOriginalPhoto: Bool) { }
    func previewControllerDidClickBack(_ controller: PhotoPreviewController) { }
    func previewControllerDidClickDone(_ controller: PhotoPreviewController) { }
}
