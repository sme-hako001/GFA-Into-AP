//
//  Array+SafeRemove.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/3/23.
//

extension Array where Element: Equatable {
    @discardableResult
    mutating func safeRemove(_ element: Element) -> Int? {
        guard let index = firstIndex(of: element) else { return .none }
        
        self.remove(at: index)
        
        return index
    }
}
