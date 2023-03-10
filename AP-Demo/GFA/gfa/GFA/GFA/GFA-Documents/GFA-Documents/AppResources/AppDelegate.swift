//
//  AppDelegate.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/30/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var gfaCoordinator: GFACoordinator! = .none
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.setupNavigationBarAppearance()

        let navigationController = UINavigationController()
        self.window?.rootViewController = navigationController

        self.gfaCoordinator = GFACoordinator(navigationController)
        
        self.gfaCoordinator.start()
                        
        return true
    }
}
