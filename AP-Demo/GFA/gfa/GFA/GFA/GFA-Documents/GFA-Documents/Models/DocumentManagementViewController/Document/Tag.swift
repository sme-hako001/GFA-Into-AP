//
//  Tag.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/2/23.
//

struct Tag: Codable, Equatable {
    let id: String
    let tag: String
    
    static let allDocumentsTag = Tag(tag: "All Documents")
    
    init(id: String = .default,
         tag: String = .default) {
        self.id = id
        self.tag = tag
    }
}


// MARK: - Tag+Hashable -

extension Tag: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.tag)
    }
}
