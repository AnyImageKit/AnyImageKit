//
//  HUDViewController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/17.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class HUDViewController: UIViewController {
    
    private lazy var coverView: UIView = {
        let view = UIView(frame: .zero)
        view.alpha = 0
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.color(hex: 0x333333)
        return view
    }()
    private lazy var indicator: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            view = UIActivityIndicatorView(style: .large)
            view.color = UIColor.white
        } else {
            view = UIActivityIndicatorView(style: .whiteLarge)
        }
        return view
    }()
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.numberOfLines = 0
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
        view.addSubview(coverView)
        coverView.addSubview(indicator)
        coverView.addSubview(label)
    }
    
    private func layout(with style: Style) {
        switch style {
        case .wait(let message):
            let labelWidth = calculateLabelWidth(with: message)
            let labelHeight = calculateLabelHeight(with: message)
            var width = labelWidth < 60 ? 100 : labelWidth + 40
            width = width > 200 ? 200 : width
            let height = labelHeight + 100
            
            coverView.snp.remakeConstraints { maker in
                maker.center.equalToSuperview()
                maker.width.equalTo(width)
                maker.height.equalTo(height)
            }
            indicator.snp.remakeConstraints { maker in
                if message.isEmpty {
                    maker.centerY.equalToSuperview()
                } else {
                    maker.centerY.equalToSuperview().offset(-(labelHeight/2+10))
                }
                maker.centerX.equalToSuperview()
                maker.width.height.equalTo(60)
            }
            label.snp.remakeConstraints { maker in
                maker.top.equalTo(indicator.snp.bottom).offset(10)
                maker.left.right.equalToSuperview().inset(20)
            }
        case .label(let message):
            let labelWidth = calculateLabelWidth(with: message)
            let labelHeight = calculateLabelHeight(with: message)
            var width = labelWidth < 60 ? 100 : labelWidth + 40
            width = width > 200 ? 200 : width
            let height = labelHeight + 30
            
            coverView.snp.remakeConstraints { maker in
                maker.center.equalToSuperview()
                maker.width.equalTo(width)
                maker.height.equalTo(height)
            }
            label.snp.remakeConstraints { maker in
                maker.centerY.equalToSuperview()
                maker.left.right.equalToSuperview().inset(20)
            }
        }
    }
    
    private func calculateLabelHeight(with message: String) -> CGFloat {
        if message.isEmpty { return 0 }
        let width: CGFloat = 160
        let attr = NSMutableAttributedString(string: message)
        attr.addAttribute(.font, value: label.font ?? .systemFont(ofSize: 16), range: NSRange(location: 0, length: attr.length))
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return attr.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil).integral.height
    }
    
    private func calculateLabelWidth(with message: String) -> CGFloat {
        if message.isEmpty { return 0 }
        let height: CGFloat = 50
        let attr = NSMutableAttributedString(string: message)
        attr.addAttribute(.font, value: label.font ?? .systemFont(ofSize: 16), range: NSRange(location: 0, length: attr.length))
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        return attr.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil).integral.width
    }
    
    // MARK: - StatusBar
    
    private var isStatusBarHidden: Bool = false
    private var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    func setStatusBar(with controller: UIViewController) {
        isStatusBarHidden = controller.prefersStatusBarHidden
        statusBarStyle = controller.preferredStatusBarStyle
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Function
extension HUDViewController {
    
    func wait(message: String = "") {
        layout(with: .wait(message))
        label.text = message
        if coverView.alpha == 1 {
            return
        }
        coverView.alpha = 0
        indicator.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.coverView.alpha = 1
        }
    }
    
    func show(message: String) {
        layout(with: .label(message))
        coverView.alpha = 0
        indicator.stopAnimating()
        label.text = message
        UIView.animate(withDuration: 0.25, animations: {
            self.coverView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.hide()
            }
        }
    }
    
    func hide(animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.coverView.alpha = 0
        }) { _ in
            self.indicator.stopAnimating()
            self.hudDidHide?()
        }
    }
}

extension HUDViewController {
    
    enum Style {
        case wait(String)
        case label(String)
    }
}
