//
//  LoadingView.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2022/11/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final public class LoadingView: UIControl {
    
    private lazy var blackView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView
        if #available(iOS 13, *) {
            view = UIActivityIndicatorView(style: .large)
        } else {
            view = UIActivityIndicatorView(style: .whiteLarge)
        }
        view.color = .white
        view.startAnimating()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.isHidden = text.isEmpty
        view.text = text
        view.textColor = .white
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 14)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [indicator, titleLabel])
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 10
        return view
    }()
    
    private let text: String
    
    public init(frame: CGRect, text: String = "") {
        self.text = text
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.text = ""
        super.init(coder: coder)
        setupView()
    }
    
}

extension LoadingView {

    private func setupView() {
        addSubview(blackView)
        addSubview(stackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLoadingView))
        addGestureRecognizer(tap)
        
        blackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            if text.isEmpty {
                make.edges.equalTo(stackView).inset(-20)
            } else {
                make.top.bottom.equalTo(stackView).inset(-15)
                make.left.right.equalTo(stackView).inset(-15)
            }
        }
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }
    
    @objc private func tapLoadingView() {
        debugPrint(#function)
    }
}

