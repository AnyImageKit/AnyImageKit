//
//  AnyImageViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

class AnyImageViewController: UIViewController {
    
    
}

// MARK: - AnyImageViewController+Permission
extension AnyImageViewController {
    
    func check(permission: Permission, authorized: @escaping (() -> Void), denied: @escaping (() -> Void)) {
        switch permission.status {
        case .notDetermined:
            permission.request { [weak self] _ in
                guard let self = self else { return }
                self.check(permission: permission, authorized: authorized, denied: denied)
            }
        case .authorized:
            authorized()
        case .denied:
            denied()
        }
    }
    
    func check(permission: Permission, authorized: @escaping (() -> Void), canceled: @escaping (() -> Void)) {
        switch permission.status {
        case .notDetermined:
            permission.request { [weak self] _ in
                guard let self = self else { return }
                self.check(permission: permission, authorized: authorized, canceled: canceled)
            }
        case .authorized:
            authorized()
        case .denied:
            let alert = UIAlertController(title: "相机被禁用", message: "请在您设备的\"设置-隐私-照片\"选项中，允许%@访问你的相机。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "设置", style: .default, handler: { [weak self] _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:]) { [weak self] result in
                    DispatchQueue.main.asyncAfter(deadline: .now()+3) { [weak self] in
                        guard let self = self else { return }
                        self.check(permission: permission, authorized: authorized, canceled: canceled)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "返回", style: .cancel, handler: { _ in
                canceled()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}
