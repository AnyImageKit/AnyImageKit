//
//  NumberCircleButton.swift
//  UI
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 RayJiang. All rights reserved.
//

import UIKit

final class NumberCircleButton: UIControl {
    
    public var num = 1 {
        didSet {
            numLabel.text = num.description
        }
    }
    
    private(set) lazy var circleIV: UIImageView = {
        let view = UIImageView()
        view.image = BundleHelper.image(named: "PickerCircleNormal")
        return view
    }()
    private(set) lazy var numLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.clipsToBounds = true
        view.text = num.description
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.backgroundColor = UIColor.green // TODO:
        return view
    }()
    
    public convenience init(style: Style) {
        self.init(frame: .zero)
        switch style {
        case .default:
            numLabel.font = UIFont.systemFont(ofSize: 14)
        case .large:
            numLabel.font = UIFont.systemFont(ofSize: 20)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(circleIV)
        addSubview(numLabel)
        circleIV.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(3)
        }
        numLabel.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(3)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numLabel.layer.cornerRadius = numLabel.bounds.width * 0.5
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if isSelected {
            numLabel.isHidden = true
        } else {
            numLabel.isHidden = false
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
        isSelected.toggle()
    }
}

extension NumberCircleButton {
    
    enum Style {
        case `default`
        case large
    }
}
