//
//  OriginalButton.swift
//  UI
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 RayJiang. All rights reserved.
//

import UIKit

final class OriginalButton: UIControl {

    private var circleView: CircleView = {
        let view = CircleView(frame: .zero)
        return view
    }()
    private lazy var label: UILabel = {
        let view = UILabel()
        view.text = "原图"
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let sv = UIStackView(arrangedSubviews: [circleView, label])
        sv.spacing = 5
        sv.isUserInteractionEnabled = false
        addSubview(sv)
        sv.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
        }
        circleView.snp.makeConstraints { (maker) in
            maker.height.equalTo(self).multipliedBy(0.6)
            maker.width.equalTo(circleView.snp.height)
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        isSelected.toggle()
        circleView.isSelected = isSelected
    }
}

fileprivate class CircleView: UIView {
    
    public var isSelected = false {
        didSet {
            smallCircleView.isHidden = !isSelected
        }
    }
    
    private lazy var bigCircleView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    private lazy var smallCircleView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.clipsToBounds = true
        view.backgroundColor = UIColor.green
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bigCircleView.layer.cornerRadius = bounds.width * 0.5
        smallCircleView.layer.cornerRadius = bounds.width * 0.5 - 3
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(bigCircleView)
        addSubview(smallCircleView)
        bigCircleView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        smallCircleView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview().inset(3)
        }
    }
    
}
