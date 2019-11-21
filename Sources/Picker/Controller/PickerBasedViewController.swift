//
//  PickerBasedViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/11/21.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol PickerBasedViewController: class {
    
    var manager: PickerManager { get }
}

extension PickerBasedViewController where Self: UIViewController {
    
    var manager: PickerManager {
        var controller: UIViewController = self
        if let presentingViewController = self.presentingViewController {
            controller = presentingViewController
        }
        guard let navigationController = controller.navigationController as? ImagePickerController else {
            fatalError("")
        }
        return navigationController.manager
    }
}
