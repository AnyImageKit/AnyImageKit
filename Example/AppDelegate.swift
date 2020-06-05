//
//  AppDelegate.swift
//  Example
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        return true
    }

}

extension AppDelegate {
    
    private func setupWindow() {
        let windows = UIWindow(frame: UIScreen.main.bounds)
        let splitController = UISplitViewController()
        splitController.preferredDisplayMode = .allVisible
        let homeController = HomeViewController(style: .grouped)
        let navigationController = UINavigationController(rootViewController: homeController)
        splitController.viewControllers = [navigationController]
        windows.rootViewController = splitController
        windows.makeKeyAndVisible()
        self.window = windows
    }
}
