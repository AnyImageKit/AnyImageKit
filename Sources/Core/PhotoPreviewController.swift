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
    public var currentIndex: Int = 0 {
        didSet {
            didSetCurrentIdx()
        }
    }
    /// 左右两张图之间的间隙
    public var photoSpacing: CGFloat = 30
    /// 图片缩放模式
    public var imageScaleMode: UIView.ContentMode = .scaleAspectFill
    /// 捏合手势放大图片时的最大允许比例
    public var imageMaximumZoomScale: CGFloat = 2.0
    /// 双击放大图片时的目标比例
    public var imageZoomScaleForDoubleTap: CGFloat = 2.0
    
    // MARK: - Private
    
    /// 是否使用原图
    private var useOriginalPhoto: Bool = false
    /// 当前正在显示视图的前一个页面关联视图
    private var relatedView: UIView? {
        return dataSource?.previewController(self, thumbnailViewForIndex: currentIndex)
    }
    /// 缩放型转场协调器
    private weak var scalePresentationController: ScalePresentationController?
    ///
    private var toolBarHiddenStateBeforePan = false
    
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
        collectionView.registerCell(PhotoPreviewCell.self)
        collectionView.registerCell(PhotoGIFPreviewCell.self)
        collectionView.registerCell(VideoPreviewCell.self)
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = false
        return collectionView
        }()
    private lazy var navigationBar: PhotoPreviewNavigationBar = {
        let view = PhotoPreviewNavigationBar()
        view.backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        view.selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var toolBar: PhotoToolBar = {
        let view = PhotoToolBar(style: .preview)
        view.originalButton.isHidden = !PhotoManager.shared.config.allowUseOriginalPhoto
        view.originalButton.isSelected = PhotoManager.shared.isOriginalPhoto
        view.leftButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        view.originalButton.addTarget(self, action: #selector(originalPhotoButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var indexView: PhotoPreviewIndexView = {
        let view = PhotoPreviewIndexView()
        view.isHidden = true
        view.delegate = self
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didSetCurrentIdx()
        setGIF(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBar(hidden: false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }
    
    @available(iOS 11.0, *)
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    deinit {
        for cell in collectionView.visibleCells {
            if let cell = cell as? PreviewCell, !cell.isSelected {
                PhotoManager.shared.cancelFetch(for: cell.asset.phAsset)
            }
        }
    }
}

// MARK: - Private function
extension PhotoPreviewController {
    /// 添加视图
    private func setupViews() {
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(collectionView)
        view.addSubview(navigationBar)
        view.addSubview(toolBar)
        view.addSubview(indexView)
        setupLayout()
        setBar(hidden: true, animated: false, isNormal: false)
        
        // TODO: 单击和双击有冲突
        //        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap))
        //        collectionView.addGestureRecognizer(singleTap)
    }
    
    //    @objc private func onSingleTap() {
    //        setBar(hidden: navigationBar.alpha == 1, animated: false)
    //    }
    
    /// 设置视图布局
    private func setupLayout() {
        navigationBar.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.right.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                maker.bottom.equalTo(topLayoutGuide.snp.bottom).offset(44)
            }
        }
        toolBar.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            if #available(iOS 11, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-56)
            } else {
                maker.top.equalTo(bottomLayoutGuide.snp.top).offset(-56)
            }
        }
        indexView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(toolBar.snp.top)
            maker.height.equalTo(96)
        }
    }
    
    /// 更新视图布局
    private func updateLayout() {
        flowLayout.minimumLineSpacing = photoSpacing
        flowLayout.itemSize = UIScreen.main.bounds.size
        collectionView.frame = view.bounds
        collectionView.frame.size.width = view.bounds.width + photoSpacing
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: photoSpacing)
    }
    
    /// 显示/隐藏工具栏
    private func setBar(hidden: Bool, animated: Bool = true, isNormal: Bool = true) {
        if navigationBar.alpha == 0 && hidden { return }
        if navigationBar.alpha == 1 && !hidden { return }
        if isNormal {
            NotificationCenter.default.post(name: .setupStatusBarHidden, object: hidden)
            scalePresentationController?.maskView.backgroundColor = hidden ? UIColor.black : ColorHelper.createByStyle(light: .white, dark: .black)
        }
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.navigationBar.alpha = hidden ? 0 : 1
                self.toolBar.alpha = hidden ? 0 : 1
                self.indexView.alpha = hidden ? 0 : 1
            }
        } else {
            navigationBar.alpha = hidden ? 0 : 1
            toolBar.alpha = hidden ? 0 : 1
            indexView.alpha = hidden ? 0 : 1
        }
    }
    
    private func didSetCurrentIdx() {
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        navigationBar.selectButton.isEnabled = true
        navigationBar.selectButton.setNum(data.asset.selectedNum, isSelected: data.asset.isSelected, animated: false)
        toolBar.hiddenEditAndOriginalButton(data.asset.type != .photo)
        indexView.currentIndex = currentIndex
    }
    
    /// 播放/暂停 GIF
    /// - Parameter animated: true-播放；false-暂停
    private func setGIF(animated: Bool) {
        for cell in collectionView.visibleCells {
            if let cell = cell as? PhotoGIFPreviewCell {
                if animated {
                    cell.imageView.startAnimating()
                } else {
                    cell.imageView.stopAnimating()
                }
            }
        }
    }
    
    /// 暂停视频
    private func stopVideo() {
        for cell in collectionView.visibleCells {
            if let cell = cell as? VideoPreviewCell {
                cell.pause()
            }
        }
    }
}

// MARK: - Target
extension PhotoPreviewController {
    
    /// NavigationBar - Back
    @objc private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .setupStatusBarHidden, object: false)
    }
    
    /// NavigationBar - Select
    @objc private func selectButtonTapped(_ sender: UIButton) {
        guard let data = dataSource?.previewController(self, assetOfIndex: currentIndex) else { return }
        if !data.asset.isSelected && PhotoManager.shared.isMaxCount {
            let message = String(format: BundleHelper.localizedString(key: "Select a maximum of %zd photos"), PhotoManager.shared.config.maxCount)
            let alert = UIAlertController(title: BundleHelper.localizedString(key: "Alert"), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: BundleHelper.localizedString(key: "OK"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        data.asset.isSelected = !sender.isSelected
        if data.asset.isSelected {
            PhotoManager.shared.addSelectedAsset(data.asset)
        } else {
            PhotoManager.shared.removeSelectedAsset(data.asset)
        }
        navigationBar.selectButton.setNum(data.asset.selectedNum, isSelected: data.asset.isSelected, animated: true)
        
        if data.asset.isSelected {
            delegate?.previewController(self, didSelected: currentIndex)
        } else {
            delegate?.previewController(self, didDeselected: currentIndex)
        }
        indexView.didChangeSelectedAsset()
    }
    
    /// ToolBar - Edit
    @objc private func editButtonTapped(_ sender: UIButton) {
        guard let cell = collectionView.visibleCells.first as? PhotoPreviewCell else { return }
        let vc = PhotoEditViewController()
        vc.imageView.image = cell.imageView.image
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    /// ToolBar - Original
    @objc private func originalPhotoButtonTapped(_ sender: OriginalButton) {
        PhotoManager.shared.isOriginalPhoto = sender.isSelected
        delegate?.previewController(self, useOriginalPhoto: sender.isSelected)
    }
    
    /// ToolBar - Done
    @objc private func doneButtonTapped(_ sender: UIButton) {
        
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoPreviewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfPhotos(in: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let data = dataSource?.previewController(self, assetOfIndex: indexPath.row) else { return UICollectionViewCell() }
        switch data.asset.type {
        case .photo:
            let cell = collectionView.dequeueReusableCell(PhotoPreviewCell.self, for: indexPath)
            cell.imageView.contentMode = imageScaleMode
            cell.delegate = self
            cell.imageMaximumZoomScale = imageMaximumZoomScale
            cell.imageZoomScaleForDoubleTap = imageZoomScaleForDoubleTap
            cell.asset = data.asset
            return cell
        case .photoGif:
            let cell = collectionView.dequeueReusableCell(PhotoGIFPreviewCell.self, for: indexPath)
            cell.delegate = self
            cell.asset = data.asset
            return cell
        case .video:
            let cell = collectionView.dequeueReusableCell(VideoPreviewCell.self, for: indexPath)
            cell.imageView.contentMode = imageScaleMode
            cell.delegate = self
            cell.asset = data.asset
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoPreviewController: UICollectionViewDelegate {
    
    /// Cell 进入屏幕 - 请求数据
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let data = dataSource?.previewController(self, assetOfIndex: indexPath.row) else { return }
        switch cell {
        case let cell as PhotoPreviewCell:
            if let originalImage = PhotoManager.shared.readCache(for: data.asset.phAsset.localIdentifier) {
                cell.setImage(originalImage)
            } else {
                cell.setImage(data.thumbnail)
                cell.requestPhoto()
            }
        case let cell as PhotoGIFPreviewCell:
            cell.requestGIF()
        case let cell as VideoPreviewCell:
            if let originalImage = PhotoManager.shared.readCache(for: data.asset.phAsset.localIdentifier) {
                cell.setImage(originalImage)
            } else {
                cell.setImage(data.thumbnail)
                cell.requestPhoto()
            }
            cell.requestVideo()
        default:
            break
        }
    }
    
    /// Cell 离开屏幕 - 重设状态
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch cell {
        case let cell as PreviewCell:
            cell.reset()
            if !cell.asset.isSelected {
                PhotoManager.shared.cancelFetch(for: cell.asset.phAsset)
            }
        default:
            break
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoPreviewController: UIScrollViewDelegate {
    
    /// 开始滑动 - 停止 GIF 和视频
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setGIF(animated: false)
        stopVideo()
    }
    
    /// 停止滑动 - 开始 GIF
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setGIF(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.width - scrollView.contentOffset.x < scrollView.bounds.width { return } // isLast
        var idx = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let x = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width)
        if x > scrollView.bounds.width / 2 {
            idx += 1
        }
        if idx != currentIndex {
            currentIndex = idx
        }
    }
}

// MARK: - PreviewCellDelegate
extension PhotoPreviewController: PreviewCellDelegate {
    
    func previewCellDidBeginPan(_ cell: PreviewCell) {
        toolBarHiddenStateBeforePan = navigationBar.alpha == 0
    }
    
    func previewCell(_ cell: PreviewCell, didPanScale scale: CGFloat) {
        // 实测用 scale 的平方，效果比线性好些
        let alpha = scale * scale
        scalePresentationController?.maskAlpha = alpha
        setBar(hidden: true, isNormal: false)
    }
    
    func previewCell(_ cell: PreviewCell, didEndPanWithExit isExit: Bool) {
        if isExit {
            dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: .setupStatusBarHidden, object: false)
        } else if !toolBarHiddenStateBeforePan {
            setBar(hidden: false, isNormal: false)
        }
    }
    
    func previewCellDidSingleTap(_ cell: PreviewCell) {
        setBar(hidden: navigationBar.alpha == 1, animated: false)
    }
    
    func previewCellGetToolBarHiddenState() -> Bool {
        return navigationBar.alpha == 0
    }
}

// MARK: - PhotoPreviewIndexViewDelegate
extension PhotoPreviewController: PhotoPreviewIndexViewDelegate {
    
    func photoPreviewSubView(_ view: PhotoPreviewIndexView, didSelect idx: Int) {
        currentIndex = idx
        collectionView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .left, animated: false)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension PhotoPreviewController: UIViewControllerTransitioningDelegate {
    /// 提供进场动画
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        updateLayout()
        // 立即加载collectionView
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        collectionView.layoutIfNeeded()
        return makeScalePresentationAnimator(indexPath: indexPath)
    }
    
    /// 提供退场动画
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return makeDismissedAnimator()
    }
    
    /// 提供转场协调器
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ScalePresentationController(presentedViewController: presented, presenting: presenting)
        scalePresentationController = controller
        return controller
    }
    
    /// 创建缩放型进场动画
    private func makeScalePresentationAnimator(indexPath: IndexPath) -> UIViewControllerAnimatedTransitioning {
        let cell = collectionView.cellForItem(at: indexPath) as? PreviewCell
        let imageView = UIImageView(image: cell?.imageView.image)
        imageView.contentMode = imageScaleMode
        imageView.clipsToBounds = true
        // 创建animator
        return ScaleAnimator(startView: relatedView, endView: cell?.imageView, scaleView: imageView)
    }
    
    /// 创建缩放型退场动画
    private func makeDismissedAnimator() -> UIViewControllerAnimatedTransitioning? {
        guard let cell = collectionView.visibleCells.first as? PreviewCell else {
            return nil
        }
        let imageView = UIImageView(image: cell.imageView.image)
        imageView.contentMode = imageScaleMode
        imageView.clipsToBounds = true
        return ScaleAnimator(startView: cell.imageView, endView: relatedView, scaleView: imageView)
    }
}
