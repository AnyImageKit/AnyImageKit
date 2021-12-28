//
//  AnyImageViewController+Permission.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/12/19.
//  Copyright © 2021 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - Permission
extension AnyImageViewController {
    
    @MainActor
    func check(permission: Permission) async -> Permission.CheckedStatus {
        let status = permission.status
        switch status {
        case .notDetermined:
            return await permission.request().checkedStatus
        default:
            return status.checkedStatus
        }
    }
    
    @MainActor
    func check(permissions: [Permission]) async -> Permission.CheckedStatus {
        if !permissions.isEmpty {
            var _permissions = permissions
            let permission = _permissions.removeFirst()
            guard await check(permission: permission) != .denied else {
                return .denied
            }
            return await check(permissions: _permissions)
        } else {
            return .authorized
        }
    }
}

// MARK: - Permission UI
extension AnyImageViewController {
    
    func check(permission: Permission, stringConfig: ThemeStringConfigurable, authorized: @escaping () -> Void, canceled: @escaping (Permission) -> Void) {
        Task {
            let checkedStatus = await self.check(permission: permission)
            switch checkedStatus {
            case .authorized, .limited:
                authorized()
            case .denied:
                let title = String(format: stringConfig[string: .permissionIsDisabled], stringConfig[string: permission.localizedTitleKey])
                let message = String(format: stringConfig[string: permission.localizedAlertMessageKey], BundleHelper.appName)
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let settings = stringConfig[string: .settings]
                alert.addAction(UIAlertAction(title: settings, style: .default, handler: { _ in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url, options: [:]) { _ in
                        canceled(permission)
                    }
                }))
                let cancel = stringConfig[string: .cancel]
                alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { _ in
                    canceled(permission)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func check(permissions: [Permission], stringConfig: ThemeStringConfigurable, authorized: @escaping () -> Void, canceled: @escaping (Permission) -> Void) {
        if !permissions.isEmpty {
            var _permissions = permissions
            let permission = _permissions.removeFirst()
            check(permission: permission, stringConfig: stringConfig, authorized: { [weak self] in
                guard let self = self else { return }
                self.check(permissions: _permissions, stringConfig: stringConfig, authorized: authorized, canceled: canceled)
            }, canceled: canceled)
        } else {
            authorized()
        }
    }
}
