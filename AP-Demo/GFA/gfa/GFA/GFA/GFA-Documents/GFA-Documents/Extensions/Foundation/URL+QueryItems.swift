//
//  URL+QueryItems.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/28/23.
//

import Foundation

extension URL {
    func safeAppending(queryItems: [URLQueryItem]) -> URL {
        (queryItems.isEmpty
         ? self
         : self.appending(queryItems: queryItems))
    }
}
