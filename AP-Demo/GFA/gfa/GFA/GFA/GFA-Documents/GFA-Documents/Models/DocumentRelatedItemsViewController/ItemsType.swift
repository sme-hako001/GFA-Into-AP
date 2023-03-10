//
//  ItemsType.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/1/23.
//

enum ItemsType {
    case tag(_ items: [IItem])
    case sticker(_ items: [IItem])
    
    var items: [IItem] {
        switch self {
        case let .tag(items): return items
        case let .sticker(items): return items
        }
    }
    
    var selectedItemsDictionary: [String: String] {
        self.selectedItems.reduce([String: String]()) {
            var selectedItemsDictionary = $0
            
            selectedItemsDictionary[$1.systemID] = $1.displayableName
            
            return selectedItemsDictionary
        }
    }
    
    var selectedItems: [IItem] {
        self.items.filter({ $0.isSelected })
    }
}
