//
//  String+Data.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/8/23.
//

import Foundation

extension String {
    var data: Data? {
        self.data(using: .utf8)
    }
}
