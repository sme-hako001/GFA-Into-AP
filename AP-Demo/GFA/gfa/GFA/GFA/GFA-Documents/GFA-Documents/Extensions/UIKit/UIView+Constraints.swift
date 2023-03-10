//
//  UIView+Constraints.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/6/23.
//

import UIKit

extension UIView {
    func addFullScreenSubview(_ subview: UIView) {
        self.addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        subview.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        subview.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        subview.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    func addCenterSubview(_ subview: UIView,
                          _ centerXConstant: CGFloat = .zero,
                          _ centerYConstant: CGFloat = .zero) {
        self.addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        subview.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: centerXConstant).isActive = true
        subview.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: centerYConstant).isActive = true
    }
    
    func addCenterSubviewAndFixSize(_ subview: UIView,
                                    _ centerXConstant: CGFloat = .zero,
                                    _ centerYConstant: CGFloat = .zero) {
        self.addCenterSubview(subview, centerXConstant, centerYConstant)
        
        subview.heightAnchor.constraint(equalToConstant: subview.bounds.height).isActive = true
        subview.widthAnchor.constraint(equalToConstant: subview.bounds.width).isActive = true
    }
    
    func addSubview(_ subview: UIView,
                    top: CGFloat? = .none,
                    left: CGFloat? = .none,
                    right: CGFloat? = .none,
                    bottom: CGFloat? = .none,
                    centerX: CGFloat? = .none,
                    centerY: CGFloat? = .none,
                    width: CGFloat? = .none,
                    height: CGFloat? = .none) {
        self.addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: top).isActive = true
        }
        
        if let left = left {
            subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: left).isActive = true
        }
        
        if let right = right {
            subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right).isActive = true
        }
        
        if let bottom = bottom {
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        }
        
        if let centerX = centerX {
            subview.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: centerX).isActive = true
        }
        
        if let centerY = centerY {
            subview.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: centerY).isActive = true
        }
        
        if let width = width {
            subview.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            subview.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
