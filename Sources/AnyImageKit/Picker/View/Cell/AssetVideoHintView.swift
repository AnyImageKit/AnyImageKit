//
//  AssetVideoHintView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/3/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class AssetVideoHintView: AnyImageView, PickerOptionsConfigurableContent {
    
    private lazy var gradientView: GradientView = makeGradientView()
    private lazy var imageView: UIImageView = makeImageView()
    private lazy var label: UILabel = makeLabel()
    
    private var optionsCancellable: AnyCancellable?
    
    let pickerContext: PickerOptionsConfigurableContext = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupDataBinding()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupDataBinding()
    }
}

// MARK: PickerOptionsConfigurableContent
extension AssetVideoHintView {
    
    func update(options: PickerOptionsInfo) {
        imageView.image = options.theme[icon: .video]
        options.theme.labelConfiguration[.assetCellVideoDuration]?.configuration(label)
    }
}

extension AssetVideoHintView {
    
    func setVideoTime(_ time: String) {
        label.isHidden = false
        label.text = time
    }
}

extension AssetVideoHintView {
    
    private func setupView() {
        addSubview(gradientView)
        addSubview(imageView)
        addSubview(label)

        gradientView.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.height.equalTo(35)
        }
        imageView.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(8)
            maker.width.equalTo(24)
            maker.height.equalTo(15)
        }
        label.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(3)
            maker.centerY.equalTo(imageView)
        }
    }
    
    private func setupDataBinding() {
        sink().store(in: &cancellables)
    }
    
    private func makeGradientView() -> GradientView {
        let view = GradientView(frame: .zero)
        view.layer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor
        ]
        view.layer.locations = [0, 1]
        view.layer.startPoint = CGPoint(x: 0.5, y: 1)
        view.layer.endPoint = CGPoint(x: 0.5, y: 0)
        return view
    }
    
    private func makeImageView() -> UIImageView {
        let view = UIImageView(frame: .zero)
        view.layer.masksToBounds = true
        return view
    }
    
    private func makeLabel() -> UILabel {
        let view = UILabel(frame: .zero)
        view.isHidden = true
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }
}
