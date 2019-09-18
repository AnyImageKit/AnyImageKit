//
//  PhotoEditViewController.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/18.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

class PhotoEditViewController: UIViewController {

    
    public let imageView = UIImageView()
    public let scrollView = UIScrollView()
    
    /// 双击放大图片时的目标比例
    public var imageZoomScaleForDoubleTap: CGFloat = 2.0
    /// 捏合手势放大图片时的最大允许比例
    public var imageMaximumZoomScale: CGFloat = 3.0 {
        didSet {
            self.scrollView.maximumZoomScale = imageMaximumZoomScale
        }
    }

//    /// 计算contentSize应处于的中心位置
//    private var centerOfContentSize: CGPoint {
//        let deltaWidth = bounds.width - scrollView.contentSize.width
//        let offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0
//        let deltaHeight = bounds.height - scrollView.contentSize.height
//        let offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0
//        return CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
//                       y: scrollView.contentSize.height * 0.5 + offsetY)
//    }

    /// 取图片适屏size
    private var fitSize: CGSize {
        guard let image = imageView.image else {
            return CGSize.zero
        }
        let width = scrollView.bounds.width
        let scale = image.size.height / image.size.width
        return CGSize(width: width, height: scale * width)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: false, completion: nil)
    }

    private func layout() {
        scrollView.frame = view.bounds
        scrollView.setZoomScale(1.0, animated: false)
        imageView.frame = fitFrame
        scrollView.setZoomScale(1.0, animated: false)
    }
}
