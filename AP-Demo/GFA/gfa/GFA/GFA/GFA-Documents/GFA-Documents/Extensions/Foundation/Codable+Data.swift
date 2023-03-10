//
//  Codable+Data.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/16/23.
//

import Foundation

extension Encodable {
    var data: Data? {
        try? JSONEncoder().encode(self)
    }
    
    var json: [String: Any]? {
        self.data?.json
    }
}

extension Data {
    func model<T: Decodable>() -> T? {
        try? JSONDecoder().decode(T.self, from: self)
    }
    
    var json: [String: Any]? {
        (try? JSONSerialization.jsonObject(with: self, options: []) as? [String : Any])
    }
}
