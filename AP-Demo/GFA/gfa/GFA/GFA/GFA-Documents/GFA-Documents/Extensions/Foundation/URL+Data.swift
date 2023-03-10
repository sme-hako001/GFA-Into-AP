//
//  URL+Data.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/17/23.
//

import Foundation

extension URL {
    var data: Data? {
        try? Data(contentsOf: self)
    }
}
