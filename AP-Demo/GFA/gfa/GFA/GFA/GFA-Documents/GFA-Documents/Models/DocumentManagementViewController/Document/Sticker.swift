//
//  Sticker.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/2/23.
//

struct Sticker: Codable, Equatable {
    let id: String
    let name: String
    
    
    init(id: String = .default,
         name: String = .default) {
        self.id = id
        self.name = name
    }
    
    init(_ info: [AnyHashable: Any]) {
        self.init(id: (info["id"] as? String).as(.default),
                  name: (info["name"] as? String).as(.default))
    }
}
