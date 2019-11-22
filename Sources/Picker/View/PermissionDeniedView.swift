//
//  PermissionDeniedView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/30.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PermissionDeniedView: UIView {
    
    private lazy var label: UILabel = {
        let view = UILabel()
        let text = String(format: BundleHelper.pickerLocalizedString(key: "Allow %@ to access your album in \"Settings -> Privacy -> Photos\""), getAppName())
        view.text = text
        view.textAlignment = .center
        view.numberOfLines = 0
        view.textColor = config.theme.textColor
        return view
    }()
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle(BundleHelper.pickerLocalizedString(key: "Go to Settings"), for: .normal)
        view.setTitleColor(config.theme.mainColor, for: .normal)
        view.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private let config: ImagePickerController.Config
    
    init(frame: CGRect, config: ImagePickerController.Config) {
        self.config = config
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = config.theme.backgroundColor
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
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - Private function
extension PermissionDeniedView {
    
    private func getAppName() -> String {
        let info = getInfoPlist()
        if let appName = info["CFBundleDisplayName"] as? String { return appName }
        if let appName = info["CFBundleName"] as? String { return appName }
        if let appName = info["CFBundleExecutable"] as? String { return appName }
        return ""
    }
    
    private func getInfoPlist() -> [String:Any] {
        var info = Bundle.main.localizedInfoDictionary
        if info == nil || info?.count == 0 {
            info = Bundle.main.infoDictionary
        }
        if info == nil || info?.count == 0 {
            let path = Bundle.main.path(forResource: "Info", ofType: "plist") ?? ""
            info = NSDictionary(contentsOfFile: path) as? [String: Any]
        }
        return info ?? [:]
    }
}
