//
//  VideoEditorToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/19.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class VideoEditorToolView: UIView {

    private(set) lazy var cancelButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle(BundleHelper.editorLocalizedString(key: "Cancel"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    private(set) lazy var doneButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 2
        view.backgroundColor = config.tintColor
        view.setTitle(BundleHelper.editorLocalizedString(key: "Done"), for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 10)
        return view
    }()
    private(set) lazy var cropButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "VideoFill"), for: .normal)
        return view
    }()
    
    private let config: ImageEditorController.VideoConfig
    
    init(frame: CGRect, config: ImageEditorController.VideoConfig) {
        self.config = config
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(cancelButton)
        addSubview(cropButton)
        addSubview(doneButton)
        
        cancelButton.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.left.equalToSuperview()
        }
        doneButton.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.right.equalToSuperview()
        }
        cropButton.snp.makeConstraints { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.centerX.equalToSuperview()
            maker.width.equalTo(cropButton.snp.height)
        }
    }
}
