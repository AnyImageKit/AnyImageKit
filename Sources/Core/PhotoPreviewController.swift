//
//  PhotoPreviewController.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

final class PhotoPreviewController: UIViewController {

    public weak var delegate: PhotoPreviewControllerDelegate? = nil
    public weak var dataSource: PhotoPreviewControllerDataSource? = nil
    
    /// 图片索引
    public var currentIndex: Int = 0
    /// 左右两张图之间的间隙
    public var photoSpacing: CGFloat = 30
    /// 图片缩放模式
    public var imageScaleMode: UIView.ContentMode = .scaleAspectFill
    /// 捏合手势放大图片时的最大允许比例
    public var imageMaximumZoomScale: CGFloat = 2.0
    /// 双击放大图片时的目标比例
    public var imageZoomScaleForDoubleTap: CGFloat = 2.0
    
    /// 是否使用原图
    private var useOriginalPhoto: Bool = false
    /// 当前正在显示视图的前一个页面关联视图
    private var relatedView: UIView? {
        return dataSource?.previewController(self, thumbnailViewForIndex: currentIndex)
    }
    /// 缩放型转场协调器
    private weak var scalePresentationController: ScalePresentationController?
    
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.registerCell(ANPhotoBrowserCell.self)
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = false
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
}

extension PhotoPreviewController: UICollectionViewDelegate {
    
}

extension PhotoPreviewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfPhotos(in: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}
