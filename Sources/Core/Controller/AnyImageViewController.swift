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

// MARK: - Permission
extension AnyImageViewController {
    
    func check(permission: Permission, authorized: @escaping () -> Void, denied: @escaping () -> Void) {
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
    
    func check(permission: Permission, authorized: @escaping () -> Void, canceled: @escaping () -> Void) {
        check(permission: permission, authorized: authorized, denied: { [weak self] in
            guard let self = self else { return }
            let title = permission.localizedAlertTitle
            let message = String(format: permission.localizedAlertMessage, BundleHelper.appName)
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let settings = BundleHelper.coreLocalizedString(key: "Settings")
            alert.addAction(UIAlertAction(title: settings, style: .default, handler: { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:]) { _ in
                    canceled()
                }
            }))
            let cancel = BundleHelper.coreLocalizedString(key: "Cancel")
            alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { _ in
                canceled()
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func check(permissions: [Permission], authorized: @escaping () -> Void, denied: @escaping (Permission) -> Void) {
        if !permissions.isEmpty {
            var _permissions = permissions
            let permission = _permissions.removeFirst()
            check(permission: permission, authorized: { [weak self] in
                guard let self = self else { return }
                self.check(permissions: _permissions, authorized: authorized, denied: denied)
            }, denied: {
                denied(permission)
            })
        } else {
            authorized()
        }
    }
    
    func check(permissions: [Permission], authorized: @escaping () -> Void, canceled: @escaping () -> Void) {
        if !permissions.isEmpty {
            var _permissions = permissions
            let permission = _permissions.removeFirst()
            check(permission: permission, authorized: { [weak self] in
                guard let self = self else { return }
                self.check(permissions: _permissions, authorized: authorized, canceled: canceled)
            }, canceled: canceled)
        } else {
            authorized()
        }
    }
}
