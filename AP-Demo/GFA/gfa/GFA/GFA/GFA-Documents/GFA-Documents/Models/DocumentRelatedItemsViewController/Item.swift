//
//  Item.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/1/23.
//

class Item: IItem {
    let displayableName: String
    let systemID: String
    let isEnabled: Bool
    var isSelected: Bool
    
    
    init(displayableName: String,
         systemID: String,
         isEnabled: Bool,
         isSelected: Bool) {
        self.displayableName = displayableName
        self.systemID = systemID
        self.isEnabled = isEnabled
        self.isSelected = isSelected
    }
}
