//
//  TestViewController.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final public class TestViewController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }
    
    private func setupView() {
        let btn = NumberCircleButton(style: .large)
        view.addSubview(btn)
        btn.snp.makeConstraints { (maker) in
            maker.top.left.equalToSuperview().offset(100)
            maker.width.height.equalTo(25)
        }
        
        let btn2 = OriginalButton()
        btn2.backgroundColor = UIColor.black
        view.addSubview(btn2)
        btn2.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(130)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(30)
        }
    }
    
}
