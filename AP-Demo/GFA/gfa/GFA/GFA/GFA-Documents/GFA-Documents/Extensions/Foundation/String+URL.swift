//
//  String+URL.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/14/23.
//

import Foundation

extension String {
    var url: URL? {
        URL(string: self)
    }
    
    var certificateURL: URL? {
        Bundle.gfa.url(forResource: self, withExtension: "der")
    }
}
