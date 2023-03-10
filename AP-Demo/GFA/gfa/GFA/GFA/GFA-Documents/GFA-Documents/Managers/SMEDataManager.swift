//
//  SMEDataManager.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/31/23.
//

import Foundation

enum DocumentListSortingField: Int {
    case author
    case added
    case title
    case type
}

final
class SMEDataManager {
    let macrosInfoProvider: MacrosInfoProvider = MacrosInfoProvider()
    let settingsManager: SMESettingsManager = SMESettingsManager()!
    let requestGenerationService: SMEHTTPRequestGenerationService = SMEHTTPRequestGenerationService()

    var allDocuments: [Document] = .default
    
    static let shared: SMEDataManager = SMEDataManager()
    
    private init() {
        
    }
    
    var documentListSortingField: DocumentListSortingField {
        return .added
    }
    
    var documentsListSortAscending: Bool {
        return true
    }
    
    func getAllDocuments(_ sheetId: String) -> [Document] {
        (self.macrosInfoProvider.is(._ONEDRIVE_SUPPORT)
         ? self.allDocuments
         : self.getSheetDataObjectWithSheetID(sheetId))
    }
    
    func isEnabled(_ action: Action) -> Bool {
        switch action {
        case .stickersAssign:
            return (self.settingsManager.user.actions.contains(.stickersAssign) ||
                    self.settingsManager.user.actions.contains(.stickersAssignAll))
        case .stickersView:
            return (self.settingsManager.user.actions.contains(.stickersView) ||
                    self.settingsManager.user.actions.contains(.stickersViewAll))
        default:
            return self.settingsManager.user.actions.contains(action)
        }
    }
    
    func hasUserPermissionForDocument(_ action: Action, _ document: Document) -> Bool {
        switch (action.asAll, action.asPublic, action) {
        case let (.some(all), _, _) where self.isEnabled(all):
            return true
        case let (_, .some(`public`), _) where self.isEnabled(`public`):
            switch (document.scope,  document.stickers.isEmpty) {
            case (.public, _): return true
            case (.protected, false): return self.hasUserStickersAssignedToDocument(document)
            case (.protected, true): return document.isOwnDocument
            case (.private, _): return document.isOwnDocument
            case (.none, _): return false
            }
        case let (_, _, normal) where self.isEnabled(normal):
            switch (document.scope, document.stickers.isEmpty) {
            case (.public, _): return document.isOwnDocument
            case (.protected, false): return (document.isOwnDocument && self.hasUserStickersAssignedToDocument(document))
            case (.protected, true): return document.isOwnDocument
            case (.private, _): return document.isOwnDocument
            case (.none, _): return false
            }
        default: return false
        }
    }
    
    private func hasUserStickersAssignedToDocument(_ document: Document) -> Bool {
        let currentUserStickersSet: Set<AnyHashable> = Set(arrayLiteral: self.settingsManager.user.stickers)
        let documentStickersSet: Set<AnyHashable> = Set(document.stickers.map({ $0.id }))
        
        let hasUserStickersAssignedToDocument = !currentUserStickersSet.intersection(documentStickersSet).isEmpty
        
        return hasUserStickersAssignedToDocument
    }
}


extension SMEDataManager {
    func sheetsDataPreloadedForSheetID(_ sheetId: String, _ selectorValuesArray: [Any] = .default) -> Bool {
        .default
    }
    
    func getSheetDataObjectWithSheetID(_ sheetId: String, _ selectorValuesArray: [Any] = .default) -> [Document] {
        .default
    }
    
    func documentDataPreloadedForFilename(_ filename: String?) -> Bool {
        guard let filename = filename else { return false }
        
        let documentURL = "\(self.settingsManager.basicURL)/download/[token]\(filename)"

        let documentDataPreloadedForURL = self.documentDataPreloadedForURL(documentURL)
        
        return documentDataPreloadedForURL
    }
    
    func documentDataPreloadedForURL(_ url: String) -> Bool {
        .default
    }
}
