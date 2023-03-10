//
//  String+Remove.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/23/23.
//

extension String {
    func remove<Target, Replacement>(of target: Target, with replacement: Replacement = String.default) -> String where Target: StringProtocol, Replacement: StringProtocol {
        self.replacingOccurrences(of: target, with: replacement)
    }
}
