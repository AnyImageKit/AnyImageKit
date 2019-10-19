//
//  PhotoEditViewController.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/18.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class PhotoEditViewController: UIViewController {
    
    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        return view
    }()
    public lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.maximumZoomScale = imageMaximumZoomScale
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()
    
    /// 捏合手势放大图片时的最大允许比例
    public var imageMaximumZoomScale: CGFloat = 3.0 {
        didSet {
            self.scrollView.maximumZoomScale = imageMaximumZoomScale
        }
    }
    
    /// 计算contentSize应处于的中心位置
    private var centerOfContentSize: CGPoint {
        let deltaWidth = view.bounds.width - scrollView.contentSize.width
        let offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0
        let deltaHeight = view.bounds.height - scrollView.contentSize.height
        let offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0
        return CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                       y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    /// 取图片适屏size
    private var fitSize: CGSize {
        guard let image = imageView.image else { return CGSize.zero }
        let width = scrollView.bounds.width
        let scale = image.size.height / image.size.width
        var size = CGSize(width: width, height: scale * width)
        let screenSize = UIScreen.main.bounds.size
        if size.width > size.height {
            size.width = size.width * screenSize.height / size.height
            size.height = screenSize.height
        }
        return size
    }
    
    /// 取图片适屏frame
    private var fitFrame: CGRect {
        let size = fitSize
        let y = (scrollView.bounds.height - size.height) > 0 ? (scrollView.bounds.height - size.height) * 0.5 : 0
        return CGRect(x: 0, y: y, width: size.width, height: size.height)
    }
    
    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    /// 返回按钮
    private lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "EditReturnBackButton"), for: .normal)
        view.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var topCoverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let statusBarHeight = StatusBarHelper.height
        layer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight + 120)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.06).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 0.7, 0.85, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()
    private lazy var bottomCoverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let height: CGFloat = 100 + (UIDevice.isMordenPhone ? 34 : 0)
        layer.frame = CGRect(x: 0, y: self.view.bounds.height-height, width: UIScreen.main.bounds.width, height: height)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.12).cgColor,
            UIColor.black.withAlphaComponent(0.06).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 0.7, 0.85, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layout()
        //        scrollView.isUserInteractionEnabled = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @available(iOS 11.0, *)
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

// MARK: - Private function
extension PhotoEditViewController {
    
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        imageView.clipsToBounds = true
        
        // 单击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap))
        view.addGestureRecognizer(singleTap)
        // 添加阴影
        view.layer.addSublayer(topCoverLayer)
        view.layer.addSublayer(bottomCoverLayer)
        
        view.addSubview(backButton)
        layout()
    }
    
    private func layout() {
        scrollView.frame = view.bounds
        scrollView.setZoomScale(1.0, animated: false)
        imageView.frame = fitFrame
        scrollView.minimumZoomScale = getDefaultScale()
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        
        backButton.snp.makeConstraints { maker in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            } else {
                maker.top.equalToSuperview().offset(40)
            }
            maker.left.equalToSuperview().offset(20)
            maker.width.height.equalTo(30)
        }
    }
    
    private func getDefaultScale() -> CGFloat {
        guard let image = imageView.image else { return 1.0 }
        let width = scrollView.bounds.width
        let scale = image.size.height / image.size.width
        let size = CGSize(width: width, height: scale * width)
        let screenSize = UIScreen.main.bounds.size
        if size.width > size.height {
            return size.height / screenSize.height
        }
        return 1.0
    }
}


// MARK: - Target
extension PhotoEditViewController {
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func onSingleTap() {
        //        delegate?.previewCellDidSingleTap(self)
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoEditViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = centerOfContentSize
    }
}
