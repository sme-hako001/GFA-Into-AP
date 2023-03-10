//
//  String+Date.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/1/23.
//

import Foundation

extension String {
    var date: Date? {
        DateFormatter.iso8601Full.date(from: self)
    }
}
