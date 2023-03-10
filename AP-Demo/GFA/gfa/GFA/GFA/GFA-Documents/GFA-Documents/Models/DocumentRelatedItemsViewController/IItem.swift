//
//  IItem.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/1/23.
//

protocol IItem {
    var displayableName: String {  get }
    var systemID: String {  get }
    var isEnabled: Bool { get }
    var isSelected: Bool { set get }
}
