//
//  UIViewController+Animate.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/6/23.
//

import UIKit

extension UIViewController {
    func animate(_ animate: Bool, _ message: String? = .none) {
        switch (animate, self.view.subviews.first(where: { $0.tag == .max } )) {
        case (true, .none):
            let animationView = UIView(frame: self.view.bounds)
            animationView.tag = .max
            animationView.backgroundColor = .white
            self.view.addFullScreenSubview(animationView)
            
            let activityIndicatorView = UIActivityIndicatorView(style: .medium)
            animationView.addCenterSubview(activityIndicatorView)
            
            activityIndicatorView.startAnimating()
            
            self.showMessageIfNeeded(animationView, message: message)
        case (false, let .some(animationView)):
            animationView.removeFromSuperview()
            
            self.showMessageIfNeeded(self.view, message: message)
        default:
            break
        }
    }
    
    private func showMessageIfNeeded(_ view: UIView, message: String?) {
        view.showMessage(show: true,
                                 message: message,
                                 left: 50,
                                 right: -50,
                                 centerX: .zero,
                                 centerY: -35)
    }
}
