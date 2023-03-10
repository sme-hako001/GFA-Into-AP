//
//  SMEStringUtils.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/3/23.
//

final class SMEStringUtils {
    static func percentEncodedURLString(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .alphanumerics).as(.default)
    }
}
