//
//  SceneDelegate.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    window = UIWindow(windowScene: windowScene)
    
    let movieViewController = MovieViewController.create()
    let navigationController = UINavigationController(rootViewController: movieViewController)
    
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
}
}

