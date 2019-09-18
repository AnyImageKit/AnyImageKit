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
    private(set) lazy var btn4: ArrowButton = {
        return ArrowButton()
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.color(hex: 0x33393C)
        setupView()
    }
    
    private func setupView() {
        view.addSubview(btn4)
        btn4.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(100)
            maker.width.equalTo(200)
            maker.height.equalTo(35)
            maker.centerX.equalToSuperview()
        }
        
        view.addSubview(btn3)
        btn3.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.height.width.equalTo(80)
        }
        btn3.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        btn4.setTitle(Bool.random() ? "相册" : "最近项目")
        
        
        let vc = PhotoPreviewController()
        vc.delegate = self
        vc.dataSource = self
//        present(vc, animated: true, completion: nil)
        
//        let controller = AlbumPickerViewController()
//        navigationController?.pushViewController(controller, animated: true)
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
