//
//  PermissionDeniedView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/30.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class PermissionDeniedView: UIView {
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(settingsButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(label)
        addSubview(button)
        label.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview().inset(15)
        }
        button.snp.makeConstraints { maker in
            maker.top.equalTo(label.snp.bottom).offset(10)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(40)
        }
    }
}

// MARK: - Target
extension PermissionDeniedView {
    
    @objc private func settingsButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - PickerOptionsConfigurable
extension PermissionDeniedView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        label.textColor = options.theme[color: .text]
        label.text = String(format: options.theme[string: Permission.photos.localizedAlertMessageKey], BundleHelper.appName)
        button.setTitleColor(options.theme[color: .primary], for: .normal)
        button.setTitle(options.theme[string: .goToSettings], for: .normal)
        backgroundColor = options.theme[color: .background]
        
        options.theme.labelConfiguration[.permissionDeniedTips]?.configuration(label)
        options.theme.buttonConfiguration[.goSettings]?.configuration(button)
    }
}
