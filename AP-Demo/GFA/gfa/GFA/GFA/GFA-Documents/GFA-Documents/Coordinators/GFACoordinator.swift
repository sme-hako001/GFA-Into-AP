//
//  GFACoordinator.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/9/23.
//

import UIKit

final
public class GFACoordinator {
    private let navigationController: UINavigationController
    private let settingsManager: SMESettingsManager = SMESettingsManager()!
    
    static public private(set) var shared: GFACoordinator! = .none
    
    
    public init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        GFACoordinator.shared = self
    }
    
    public func start(cleanCredentials: Bool = false) {
        if cleanCredentials {
            self.settingsManager.clean()
        }
        
        self.setRootToIntroLoginViewController()
    }
    
    func setRootToIntroLoginViewController() {
        self.setRoot(
            IntroLoginViewController()
        )
    }
    
    func setRootToLoginUSMViewController() {
        self.setRoot(
            LoginUSMViewController()
        )
    }
    
    func setRootToDocumentViewerTVController() {
        self.setRoot(
            DocumentViewerTVController()
        )
    }
    
    func performPasswordConfirmationRequest() {
        // FIXME: - Should Be Implemented In The Future -
    }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        let rootViewController = self.navigationController
        
        let present: () -> Void = {
            rootViewController.present(viewController, animated: animated, completion: completion)
        }
        
        ((rootViewController.presentedViewController).isNil
         ? present()
         : rootViewController.presentedViewController?.dismiss(animated: true, completion: present))
    }
    
    
    // MARK: - Private Implementation -
    
    private func setRoot(_ viewController: UIViewController) {
        self.navigationController.setViewControllers([viewController], animated: false)
    }
}
