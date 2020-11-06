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
        let homeController: HomeViewController
        if #available(iOS 13.0, *) {
            homeController = HomeViewController(style: .insetGrouped)
        } else {
            homeController = HomeViewController(style: .grouped)
        }
        let navigationController = UINavigationController(rootViewController: homeController)
        windows.rootViewController = navigationController
        windows.makeKeyAndVisible()
        self.window = windows
    }
}
