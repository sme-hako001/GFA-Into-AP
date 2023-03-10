//
//  GradientButton.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/4/23.
//

import UIKit

class GradientButton: UIButton {
    @IBInspectable var firstColor: UIColor = .clear
    @IBInspectable var secondColor: UIColor = .clear
    @IBInspectable var topToBottom: Bool = true

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGradientBackgound(firstColor: firstColor,
                                  secondColor: secondColor,
                                  gradientDirection: self.topToBottom
                                  ? .topToBottom
                                  : .bottomToTop)
    }
    
    
    // MARK: - Private Methods -
    
    func addGradientBackgound(firstColor: UIColor, secondColor: UIColor, gradientDirection: GradientDirection, addGradientAdditionalWidth: Bool = true) {
        self.layoutIfNeeded()
        
        self.layer.sublayers?.forEach({ (layer) in
            if layer.name == "grad" {
                layer.removeFromSuperlayer()
            }
        })
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [firstColor.cgColor, secondColor.cgColor]
        gradient.locations = [0.0 , 1.0]
        switch gradientDirection {
        case .topToBottom:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        case .bottomToTop:
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        case .leftToRight:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        case .rightToLeft:
            gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        }
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width + (addGradientAdditionalWidth ? 2 : 0), height: self.bounds.size.height)
        gradient.name = "grad"
        self.layer.insertSublayer(gradient, at: 0)
    }
}
