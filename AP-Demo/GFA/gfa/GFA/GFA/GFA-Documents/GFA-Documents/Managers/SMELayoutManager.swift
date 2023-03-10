//
//  SMELayoutManager.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/31/23.
//

import UIKit

final
class SMELayoutManager {
    let kLayoutSizeK: CGFloat
    let kLayoutFontK: CGFloat
    let kLayoutButtonK: CGFloat
    let kLayoutWidth: CGFloat
    let kLayoutStatusBarShift: CGFloat
    let kLayoutTabbarHeight: CGFloat
    let kLayoutMenuWidth: CGFloat
    let kLayoutTabbarWidth: CGFloat
    
    
    init() {
        let isIPhone = UIDevice.current.isIPhone
        
        self.kLayoutSizeK = (isIPhone ? 0.54 : 1)
        self.kLayoutFontK = (isIPhone ? 0.7 : 1)
        self.kLayoutButtonK = (isIPhone ? 0.65 : 1)
        self.kLayoutWidth = (isIPhone ? 80 : 149)
        self.kLayoutTabbarHeight = (isIPhone ? 90 * 0.7 : 90)
        self.kLayoutMenuWidth = (isIPhone ? 160 * 0.7 : 160)
        self.kLayoutTabbarWidth = (isIPhone ? 414 : 768)
        self.kLayoutStatusBarShift = (isIPhone ? 44 : ((UIDevice.current.systemVersion as NSString).floatValue >= 7.0 ? 64 : 0))
    }
}
