//
//  AnyImageViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

class AnyImageViewController: UIViewController {
    
    private var page: AnyImagePage = .undefined
    private var isStatusBarHidden: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var cancellables: Set<AnyCancellable> = .init()
    var listCancellables: [IndexPath: AnyCancellable] = .init()
    
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
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    func setStatusBar(hidden: Bool) {
        isStatusBarHidden = hidden
    }
}

// MARK: - Function
extension AnyImageViewController {
    
    func showAlert(message: String, stringConfig: ThemeStringConfigurable) {
        let alert = UIAlertController(title: stringConfig[string: .alert], message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: stringConfig[string: .ok], style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Data Track
extension AnyImageViewController {
    
    private func setTrackPage() {
        switch self {
        #if ANYIMAGEKIT_ENABLE_PICKER
        case _ as PhotoLibraryListViewController:
            page = .pickerAlbum
        case _ as PhotoAssetCollectionViewController:
            page = .pickerAsset
        case _ as PhotoPreviewController:
            page = .pickerPreview
        #endif
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        case _ as PhotoEditorController:
            page = .editorPhoto
        case _ as VideoEditorController:
            page = .editorVideo
        case _ as InputTextViewController:
            page = .editorInputText
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
            } else if let navigationController = presentingViewController as? AnyImageNavigationController {
                controller.trackDelegate = navigationController.trackDelegate
            }
        }
    }
}

// MARK: - HUD
extension AnyImageViewController {
    
    func showWaitHUD(_ message: String = "") {
        _showWaitHUD(self, message)
    }

    func showMessageHUD(_ message: String) {
        _showMessageHUD(self, message)
    }

    func hideHUD(animated: Bool = true) {
        _hideHUD(self, animated: animated)
    }
}
