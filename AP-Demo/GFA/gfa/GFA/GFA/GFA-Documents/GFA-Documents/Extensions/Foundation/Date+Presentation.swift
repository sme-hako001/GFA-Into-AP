//
//  Date+Presentation.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/22/23.
//

import Foundation

extension Date {
    var presentation: String {
        DateFormatter.medium.string(from: self)
    }
}
