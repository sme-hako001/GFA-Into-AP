//
//  FilterMetric.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/3/23.
//

struct FilterMetric: Equatable {
    var searchText: String
    var selectedTag: Tag
    
    static let `default` = FilterMetric(searchText: .default, selectedTag: .allDocumentsTag)
}
