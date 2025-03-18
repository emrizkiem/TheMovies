//
//  SceneDelegate.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import UIKit
import Swinject

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    guard let movieViewController = DependencyContainer.shared.container.resolve(MovieViewController.self) else {
      return
    }
    
    window = UIWindow(windowScene: windowScene)
    
    let navigationController = UINavigationController(rootViewController: movieViewController)
    
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
}
