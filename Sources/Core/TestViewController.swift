//
//  TestViewController.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final public class TestViewController: UIViewController {

    private(set) lazy var btn3: UIButton = {
        let view = UIButton(type: .custom)
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
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
        
        view.addSubview(btn3)
        btn3.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.height.width.equalTo(50)
        }
        btn3.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
//        let vc = PhotoPreviewController()
//        vc.delegate = self
//        vc.dataSource = self
//        presentAsPush(vc)
        
        let controller = AlbumPickerViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension TestViewController: PhotoPreviewControllerDelegate, PhotoPreviewControllerDataSource {
    func previewController(_ controller: PhotoPreviewController, thumbnailViewForIndex index: Int) -> UIView? {
        return btn3
    }
    
    func previewController(_ controller: PhotoPreviewController, assetOfIndex index: Int) -> Asset {
        fatalError()
    }
    
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int) -> Int {
        return 1
    }
    
    func numberOfPhotos(in controller: PhotoPreviewController) -> Int {
        return 10
    }
    
    
}
