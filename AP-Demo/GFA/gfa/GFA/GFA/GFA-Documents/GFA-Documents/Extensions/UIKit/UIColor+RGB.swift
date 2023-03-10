//
//  UIColor+RGB.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/27/23.
//

import UIKit

extension UIColor {
    static func color(_ rgbValue: UInt) -> UIColor {
        UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
