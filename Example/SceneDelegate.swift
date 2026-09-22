//
//  SceneDelegate.swift
//  Example
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let homeController = HomeViewController(style: .insetGrouped)
        let navigationController = UINavigationController(rootViewController: homeController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
