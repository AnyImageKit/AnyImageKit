//
//  NumberCircleButton.swift
//  UI
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 RayJiang. All rights reserved.
//

import UIKit

final class NumberCircleButton: UIControl {
    
    private lazy var circleView: CircleView = {
        let view = CircleView(style: style)
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var numLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.clipsToBounds = true
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.backgroundColor = PhotoManager.shared.config.theme.mainColor
        return view
    }()
    private let style: Style
    
    init(frame: CGRect, style: Style) {
        self.style = style
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(circleView)
        addSubview(numLabel)
        circleView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(4)
        }
        numLabel.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(3)
        }
        switch style {
        case .default:
            numLabel.font = UIFont.systemFont(ofSize: 14)
        case .large:
            numLabel.font = UIFont.systemFont(ofSize: 18)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numLabel.layer.cornerRadius = numLabel.bounds.width * 0.5
    }
    
    private func showNumber(_ animated: Bool) {
        if isSelected {
            numLabel.isHidden = false
            if animated {
                self.numLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                UIView.animate(withDuration: 0.15, animations: {
                    self.numLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }) { (_) in
                    UIView.animate(withDuration: 0.15, animations: {
                        self.numLabel.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    }) { (_) in
                        UIView.animate(withDuration: 0.15) {
                            self.numLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        }
                    }
                }
            }
        } else {
            numLabel.isHidden = true
        }
    }
}

extension NumberCircleButton {
    
    func setNum(_ num: Int, isSelected: Bool, animated: Bool) {
        self.isSelected = isSelected
        numLabel.text = num.description
        showNumber(animated)
    }
}

extension NumberCircleButton {
    
    enum Style {
        case `default`
        case large
    }
}

extension NumberCircleButton {
    
    private class CircleView: UIView {
        
        private lazy var imageView: UIImageView = {
            let view = UIImageView(frame: .zero)
            let style = PhotoManager.shared.config.theme.style
            view.image = BundleHelper.image(named: "PickerCircle", style: style)
            return view
        }()
        
        init(style: Style) {
            super.init(frame: .zero)
            switch style {
            case .default:
                backgroundColor = UIColor.gray.withAlphaComponent(0.25)
                layer.masksToBounds = true
                layer.borderColor = UIColor.white.cgColor
                layer.borderWidth = 1.5
            case .large:
                addSubview(imageView)
                imageView.snp.makeConstraints { maker in
                    maker.edges.equalToSuperview()
                }
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = bounds.size.width/2
        }
    }
}
