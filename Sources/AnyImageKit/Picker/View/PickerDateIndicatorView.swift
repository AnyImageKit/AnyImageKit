//
//  PickerDateIndicatorView.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2024/10/31.
//  Copyright © 2024 AnyImageKit.org. All rights reserved.
//

import UIKit

/// Show the date at the top of collection view when scrollIndicator = .verticalBar
final class PickerDateIndicatorView: UIView {
    
    private lazy var topShadowView: GradientView = {
        let view = GradientView(frame: .zero)
        view.layer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
        ]
        view.layer.locations = [0, 0.6, 1]
        view.layer.startPoint = CGPoint(x: 0.5, y: 0)
        view.layer.endPoint = CGPoint(x: 0.5, y: 1)
        return view
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        view.textAlignment = .center
        return view
    }()
    
    private let formatter = DateFormatter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public
extension PickerDateIndicatorView {
    
    public func update(_ first: Asset?, options: PickerOptionsInfo) {
        guard let firstDate = first?.phAsset.creationDate else {
            isHidden = true
            return
        }
        isHidden = false
        formatter.dateFormat = options.theme[string: .fullDateFormat]
        dateLabel.text = formatter.string(from: firstDate)
    }
}

// MARK: - UI
extension PickerDateIndicatorView {
    
    private func setupView() {
        addSubview(topShadowView)
        addSubview(dateLabel)
        
        topShadowView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(topShadowView).offset(-15)
            make.height.equalTo(44)
        }
    }
}
