//
//  Documents+Tags.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/3/23.
//

import Foundation

extension [Document] {
    func getAllTags() -> [Tag] {
        var allTags =  self.flatMap({ $0.tags })
        allTags.insert(.allDocumentsTag, at: .zero)
        
        let allTagsSet = Set(allTags)
        let allTagsArray = Array<Tag>(allTagsSet)
        
        return allTagsArray
    }
}
