//
//  AssetGIFHintView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/3/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class AssetGIFHintView: UIView, PickerOptionsConfigurableContent {
    
    private lazy var gradientView: GradientView = makeGradientView()
    private lazy var gifLabel: UILabel = makeLabel()
    
    private var optionsCancellable: AnyCancellable?
    
    let pickerContext: PickerOptionsConfigurableContext = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
}

// MARK: - PickerOptionsConfigurableContent
extension AssetGIFHintView {
    
    func update(options: PickerOptionsInfo) {
        options.theme.labelConfiguration[.assetCellGIFMark]?.configuration(gifLabel)
    }
}

// MARK: UI
extension AssetGIFHintView {
    
    private func setupView() {
        addSubview(gradientView)
        addSubview(gifLabel)
        
        gradientView.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.height.equalTo(35)
        }
        
        gifLabel.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(8)
            maker.height.equalTo(15)
        }
    }
    
    private func setupDataBinding() {
        optionsCancellable = sink()
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
    
    private func makeLabel() -> UILabel {
        let view = UILabel(frame: .zero)
        view.text = "GIF"
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return view
    }
}
