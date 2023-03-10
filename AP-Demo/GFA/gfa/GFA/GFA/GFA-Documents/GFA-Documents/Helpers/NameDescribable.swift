//
//  NameDescribable.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/27/23.
//

import Foundation

protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    var typeName: String { String(describing: Self.self) }
    static var typeName: String { String(describing: self) }
}

extension NSObject: NameDescribable {
    
}
