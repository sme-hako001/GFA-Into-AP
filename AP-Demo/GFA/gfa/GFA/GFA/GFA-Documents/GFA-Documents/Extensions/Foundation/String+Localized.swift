//
//  String+Localized.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/1/23.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .gfa, comment: .default)
    }
    
    func localized(_ arguments: CVarArg...) -> String {
        String(format: self.localized, arguments)
    }
}
