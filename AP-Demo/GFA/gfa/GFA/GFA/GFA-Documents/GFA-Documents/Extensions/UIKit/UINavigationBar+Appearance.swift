//
//  UINavigationBar+Appearance.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/4/23.
//

import UIKit

extension UINavigationBar {
    static func setupNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.red]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}
