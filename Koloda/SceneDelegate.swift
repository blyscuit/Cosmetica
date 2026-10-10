//
//  SceneDelegate.swift
//  Cosmetica
//
//  Created by Pisit Wetchaya on 10/10/2569 BE.
//  Copyright © 2569 BE CocoaPods. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let window = UIWindow(windowScene: windowScene)

        window.rootViewController = storyboard.instantiateInitialViewController()
        self.window = window

        window.makeKeyAndVisible()
    }
}
