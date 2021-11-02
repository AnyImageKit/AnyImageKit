//
//  MirrorCropView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/2.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
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
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
            make.left.equalToSuperview()
            make.width.equalTo(rect.minX)
        }
        rightView.snp.remakeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(rect.maxX)
        }
        bottomView.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(rect.maxY)
        }
    }
    
}
