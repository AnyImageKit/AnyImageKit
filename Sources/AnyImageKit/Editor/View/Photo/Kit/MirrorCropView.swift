//
//  MirrorCropView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/2.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class MirrorCropView: UIView {
    
    var color: UIColor = .black {
        didSet {
            topView.backgroundColor = color
            leftView.backgroundColor = color
            rightView.backgroundColor = color
            bottomView.backgroundColor = color
        }
    }
    
    private lazy var topView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        return view
    }()
    private lazy var leftView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        return view
    }()
    private lazy var rightView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        return view
    }()
    private lazy var bottomView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(topView)
        addSubview(leftView)
        addSubview(rightView)
        addSubview(bottomView)
    }
    
    func setRect(_ rect: CGRect) {
        topView.snp.remakeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(rect.minY)
        }
        leftView.snp.remakeConstraints { make in
            make.top.equalTo(rect.minY)
            make.bottom.equalTo(rect.maxY)
            make.left.equalToSuperview()
            make.width.equalTo(rect.minX)
        }
        rightView.snp.remakeConstraints { make in
            make.top.equalTo(rect.minY)
            make.bottom.equalTo(rect.maxY)
            make.left.equalToSuperview().offset(rect.maxX)
            make.right.equalToSuperview()
        }
        bottomView.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(rect.maxY)
        }
    }
    
}
