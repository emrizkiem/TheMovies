//
//  AppDelegate.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 17/03/25.
//

import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    guard let movieViewController = DependencyContainer.shared.container.resolve(MovieViewController.self) else {
      return false
    }
  
    if #available(iOS 13.0, *) {
      
    } else {
      window = UIWindow(frame: UIScreen.main.bounds)
      
      let navigationController = UINavigationController(rootViewController: movieViewController)
      window?.rootViewController = navigationController
      window?.makeKeyAndVisible()
    }
    
    return true
  }
  
  @available(iOS 13.0, *)
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}

