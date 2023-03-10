//
//  DocumentPermission.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/2/23.
//

enum Action: String, Codable {
    case documentsViewAll = "documents view all"
    case documentsViewPublic = "documents view public"
    case documentsView = "documents view"
    case documentsManageAll = "documents manage all"
    case documentsManagePublic = "documents manage public"
    case documentsManage = "documents manage"
    case stickersAssignAll = "stickers assign all"
    case stickersAssign = "stickers assign"
    case tagsView = "tags view"
    case stickersViewAll = "stickers view all"
    case stickersView = "stickers view"
    
    var asAll: Action? {
        Action(rawValue: self.rawValue.appending(" all"))
    }
    
    var asPublic: Action? {
        Action(rawValue: self.rawValue.appending(" public"))
    }
}
