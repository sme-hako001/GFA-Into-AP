//
//  String+Empty.swift
//  GFA-Documents
//
//  Created by Margarita N. Bock on 23.02.2023.
//

import Foundation

extension String {
    func isEmptyOrWhitespace() -> Bool {
        if(self.isEmpty) {
            return true
        }
        return (self.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")
    }
}
