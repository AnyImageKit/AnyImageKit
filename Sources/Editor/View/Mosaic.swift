//
//  Mosaic.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/25.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol MosaicDelegate: class {
    
    func mosaicDidBeginPen()
    func mosaicDidEndPen()
}

protocol MosaicDataSource: class {
    
    func mosaicGetScale(_ mosaic: Mosaic) -> CGFloat
}

final class Mosaic: UIView {
    
    weak var dataSource: MosaicDataSource?
    weak var delegate: MosaicDelegate?
    
    private let originalMosaicImage: UIImage
    private let mosaicOptions: [AnyImageEditorPhotoMosaicOption]
    private let lineWidth: CGFloat
    
    /// 当前马赛克覆盖的图片
    private var mosaicImage: UIImage!
    /// 马赛克覆盖图片
    private var mosaicCoverImage: [UIImage] = []
    /// 展示马赛克图片的涂层
    private var mosaicImageLayer = CALayer()
    /// 遮罩层，用于设置形状路径
    private var shapeLayer = CAShapeLayer()
    /// 手指涂抹的路径
    private var path = CGMutablePath()
    private var tmpPath = CGMutablePath()
    private var lastPoint: CGPoint = .zero
    /// 步长
    private var lenth = 0
    /// 当前马赛克的下标
    var currentIdx: Int {
        return mosaicCoverImage.firstIndex(of: mosaicImage) ?? 0
    }
    
    
    init(frame: CGRect, originalMosaicImage: UIImage, mosaicOptions: [AnyImageEditorPhotoMosaicOption], lineWidth: CGFloat) {
        self.originalMosaicImage = originalMosaicImage
        self.mosaicOptions = mosaicOptions
        self.lineWidth = lineWidth
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // create
        for option in mosaicOptions {
            let image: UIImage
            switch option {
            case .default:
                image = originalMosaicImage
            case .colorful:
                image = BundleHelper.image(named: "CustomMosaic")!
            case .custom(_, let customMosaic):
                image = customMosaic
            }
            mosaicCoverImage.append(image)
        }
        setMosaicCoverImage(0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        pushPoint(point, state: .begin)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        pushPoint(point, state: .move)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        pushPoint(point, state: .end)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        pushPoint(point, state: .cancel)
    }
}

// MARK: - Public function
extension Mosaic {
    
    func setMosaicCoverImage(_ idx: Int) {
        mosaicImage = mosaicCoverImage[idx]
        reset()
    }
    
    func reset() {
        shapeLayer.removeFromSuperlayer()
        mosaicImageLayer.removeFromSuperlayer()
        
        path = CGMutablePath()
        shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        let sacle = dataSource?.mosaicGetScale(self) ?? 1.0
        shapeLayer.lineWidth = lineWidth / sacle
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = nil
        mosaicImageLayer = CALayer()
        mosaicImageLayer.frame = frame
        mosaicImageLayer.contents = mosaicImage.cgImage
        
        layer.addSublayer(mosaicImageLayer)
        layer.addSublayer(shapeLayer)
        mosaicImageLayer.mask = shapeLayer
    }
}

// MARK: - Private function
extension Mosaic {
    
    private func pushPoint(_ point: CGPoint, state: TouchState) {
        switch state {
        case .begin:
            let sacle = dataSource?.mosaicGetScale(self) ?? 1.0
            shapeLayer.lineWidth = lineWidth / sacle
            
            lenth = 0
            tmpPath = CGMutablePath()
            tmpPath.move(to: point)
            lastPoint = point
        case .move:
            if lastPoint == point { return }
            lastPoint = point
            lenth += 1
            if lenth <= 3 {
                tmpPath.addLine(to: point)
            } else {
                path.addLine(to: point)
            }
        default:
            break
        }
        
        if lenth <= 2 { return }
        if lenth == 3 {
            path.addPath(tmpPath)
            delegate?.mosaicDidBeginPen()
        }
        guard let copyPath = path.copy() else { return }
        shapeLayer.path = copyPath
        
        guard state == .end || state == .cancel else { return }
        delegate?.mosaicDidEndPen()
    }
}
