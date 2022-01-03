//
//  CapturePreviewMaskView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/10.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class CapturePreviewMaskView: UIView {
    
    private var maskColor: UIColor = UIColor.black.withAlphaComponent(0.25)
    
    private(set) lazy var topMaskView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = maskColor
        return view
    }()
    
    private lazy var centerLayoutGuide: UILayoutGuide = {
        let layoutGuide = UILayoutGuide()
        return layoutGuide
    }()
    
    private(set) lazy var bottomMaskView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = maskColor
        return view
    }()
    
    private let options: CaptureOptionsInfo
    
    init(frame: CGRect, options: CaptureOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addLayoutGuide(centerLayoutGuide)
        addSubview(topMaskView)
        addSubview(bottomMaskView)
        topMaskView.snp.makeConstraints { maker in
            maker.top.equalTo(snp.top)
            maker.left.equalTo(snp.left)
            maker.right.equalTo(snp.right)
        }
        centerLayoutGuide.snp.makeConstraints { maker in
            maker.top.equalTo(topMaskView.snp.bottom)
            maker.left.equalTo(snp.left)
            maker.right.equalTo(snp.right)
            
            switch options.mediaOptions {
            case [.photo, .video]:
                // mix mode
                maker.width.equalTo(centerLayoutGuide.snp.height).multipliedBy(options.photoAspectRatio.value)
            case [.photo]:
                // photo mode
                maker.width.equalTo(centerLayoutGuide.snp.height).multipliedBy(options.photoAspectRatio.value)
                setMaskColorAlpha(1.0)
            case [.video]:
                // video mode
                maker.width.equalTo(centerLayoutGuide.snp.height).multipliedBy(9.0/16.0)
            default:
                break
            }
        }
        bottomMaskView.snp.makeConstraints { maker in
            maker.top.equalTo(centerLayoutGuide.snp.bottom)
            maker.left.equalTo(snp.left)
            maker.right.equalTo(snp.right)
            maker.bottom.equalTo(snp.bottom)
            maker.height.equalTo(topMaskView.snp.height)
        }
    }
}

extension CapturePreviewMaskView {
    
    func setMaskColor(_ color: UIColor) {
        maskColor = color
        topMaskView.backgroundColor = color
        bottomMaskView.backgroundColor = color
    }
    
    func setMaskColorAlpha(_ alpha: CGFloat) {
        let color = maskColor.withAlphaComponent(alpha)
        setMaskColor(color)
    }
}
