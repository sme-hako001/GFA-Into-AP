//
//  UIDevice+IsIPhone.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/31/23.
//

import UIKit

extension UIDevice {
    var isIPhone: Bool {
        (self.userInterfaceIdiom == .phone)
    }
}
