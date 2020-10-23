//
//  AnyImageViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

class AnyImageViewController: UIViewController {
    
    private var page: AnyImagePage = .undefined
    
    weak var trackObserver: DataTrackObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTrackPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackObserver?.track(page: page, state: .enter)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        trackObserver?.track(page: page, state: .leave)
    }
   
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        setTrackObserverOrDelegate(viewControllerToPresent)
        super.present(viewControllerToPresent, animated: true, completion: completion)
    }
}

// MARK: - Data Track
extension AnyImageViewController {
    
    private func setTrackPage() {
        switch self {
        #if ANYIMAGEKIT_ENABLE_PICKER
        case _ as AlbumPickerViewController:
            page = .albumPicker
        case _ as AssetPickerViewController:
            page = .assetPicker
        case _ as PhotoPreviewController:
            page = .photoPreview
        #endif
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        case _ as PhotoEditorController:
            page = .photoEditor
        case _ as VideoEditorController:
            page = .videoEditor
        #endif
            
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        case _ as CaptureViewController:
            page = .capture
        case _ as PadCaptureViewController:
            page = .capture
        #endif
            
        default:
            page = .undefined
        }
    }
    
    private func setTrackObserverOrDelegate(_ target: UIViewController) {
        if let controller = target as? AnyImageViewController {
            controller.trackObserver = trackObserver
        } else if let controller = target as? AnyImageNavigationController {
            if let navigationController = navigationController as? AnyImageNavigationController {
                controller.trackDelegate = navigationController.trackDelegate
            } else if let navigationController = presentingViewController?.navigationController as? AnyImageNavigationController {
                controller.trackDelegate = navigationController.trackDelegate
            }
        }
    }
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
        case .authorized, .limited:
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
