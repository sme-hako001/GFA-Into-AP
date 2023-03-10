//
//  UIView+ShowMessage.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/7/23.
//

import UIKit

extension UIView {
    func showMessage(show: Bool = true,
                     message: String? = .none,
                     top: CGFloat? = .none,
                     left: CGFloat? = .none,
                     right: CGFloat? = .none,
                     bottom: CGFloat? = .none,
                     centerX: CGFloat? = .none,
                     centerY: CGFloat? = .none,
                     width: CGFloat? = .none,
                     height: CGFloat? = .none) {
        switch (show,
                message,
                self.subviews.first(where: { $0.tag == .min } )) {
        case (true, .some(let message), .none):
            let messageLabel = UILabel()
            messageLabel.tag = .min
            messageLabel.text = message
            messageLabel.numberOfLines = .zero
            messageLabel.textColor = .black
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            messageLabel.sizeToFit()
            
            self.addSubview(messageLabel,
                            top: top,
                            left: left,
                            right: right,
                            bottom: bottom,
                            centerX: centerX,
                            centerY: centerY,
                            width: width,
                            height: height)
        case (false, _, .some(let messageLabel)):
            messageLabel.removeFromSuperview()
        default:
            break
        }
    }
}
