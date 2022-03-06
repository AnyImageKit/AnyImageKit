//
//  AssetPlugin+Capture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/3/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class CameraAssetPlugin: AssetPlugin {
    
    override var identifier: String {
        return "org.AnyImageKit.AssetPlugin.Buildin.Camera"
    }
    
    override func register(_ context: AssetPlugin.RegisterContext) {
        context.collectionView.registerCell(CameraAssetCell.self)
    }
    
    override func dequeue(_ context: AssetPlugin.DequeueContext) -> UICollectionViewCell & PickerOptionsConfigurableContent {
        context.collectionView.dequeueReusableCell(CameraAssetCell.self, for: context.indexPath)
    }
    
    override func select(_ context: AssetPlugin.SelectContext) {
        #if !targetEnvironment(simulator)
//        var captureOptions = context.controller.options.captureOptions
//        let controller = ImageCaptureController(options: captureOptions, delegate: self)
//        context.controller.present(controller, animated: true, completion: nil)
        #else
        let alert = UIAlertController(title: "Error", message: "Camera is unavailable on simulator", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        context.controller.present(alert, animated: true, completion: nil)
        #endif
    }
}

final class CameraAssetCell: UICollectionViewCell, PickerOptionsConfigurableContent {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var sinkCancellable: AnyCancellable?
    
    let pickerContext: PickerOptionsConfigurableContext = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.color(hex: 0xDEDFE0)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(self.snp.width).multipliedBy(0.5)
        }
        
        sinkCancellable = sink()
    }
    
    func update(options: PickerOptionsInfo) {
        imageView.image = options.theme[icon: .camera]
        accessibilityLabel = options.theme[string: .pickerTakePhoto]
    }
}
