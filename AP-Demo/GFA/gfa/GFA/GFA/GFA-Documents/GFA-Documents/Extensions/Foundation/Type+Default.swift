//
//  Type+Default.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/16/23.
//

import UIKit

extension Data {
    static let `default` = Data()
}

extension Bool {
    static let `default` = Bool()
}

extension Int {
    static let `default` = Int()
}

extension String {
    static let `default` = String()
}

extension Date {
    static let `default` = Date()
}

extension URL {
    static let `default`: URL = URL(string: "https://www.apple.com")!
}

extension Array {
    static var `default`: Array<Element> {
        get { Array<Element>() }
    }
}

extension Dictionary where Key: Hashable, Value: Any {
    static var `default`: [Key: Value] {
        get { [:] }
    }
}

extension UIImage {
    static let `default` = UIImage()
}
