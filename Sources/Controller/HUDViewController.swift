//
//  HUDViewController.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/10/17.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class HUDViewController: UIViewController {
    
    private lazy var indicatorCoverView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.color(hex: 0x333333)
        return view
    }()
    private lazy var labelCoverView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.color(hex: 0x333333)
        return view
    }()
    private lazy var indicator: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView
        if #available(iOS 13, *) {
            view = UIActivityIndicatorView(style: .large)
            view.color = UIColor.white
        } else {
            view = UIActivityIndicatorView(style: .whiteLarge)
        }
        return view
    }()
    private lazy var label: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    var hudDidHide: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        setupView()
    }
    
    private func setupView() {
        view.addSubview(indicatorCoverView)
        indicatorCoverView.addSubview(indicator)
        view.addSubview(labelCoverView)
        labelCoverView.addSubview(label)
        
        indicatorCoverView.snp.remakeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(100)
        }
        indicator.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(60)
        }
        labelCoverView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        label.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview().inset(15)
            maker.left.right.equalToSuperview().inset(20)
        }
    }
}

extension HUDViewController {
    
    func wait() {
        labelCoverView.alpha = 0
        indicator.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.indicatorCoverView.alpha = 1
        }
    }
    
    func show(message: String) {
        indicatorCoverView.alpha = 0
        label.text = message
        UIView.animate(withDuration: 0.25, animations: {
            self.labelCoverView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.hide()
            }
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.indicatorCoverView.alpha = 0
            self.labelCoverView.alpha = 0
        }) { _ in
            self.hudDidHide?()
        }
    }
}
