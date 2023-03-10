//
//  Document.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/2/23.
//

import Foundation
import UIKit

class Document: Decodable, Equatable, Comparable {
    let id: String
    let user: String
    let title: String
    let mimiType: MimeType
    let createdAt: Date
    let hash: String
    let filename: String
    var scope: Scope
    var tags: [Tag]
    var stickers: [Sticker]
    
    let path: String?
    let localFilePath: String
    var localFileURL: URL
    var data: Data
    var thumbnail: UIImage?
    
    let smeDocumentId: String?
    let oneDriveItemId: String?
    let oneDrivePath: String?
    
    let hasRelatedGFADocument: Bool
    let hasRelatedOneDriveDocument: Bool
    let isOneDriveDocument: Bool
    
    let needGFA: Bool
    let needOneDrive: Bool
    
    let oneDriveTitle: String

    let isOwnDocument: Bool
    
    static let `default` = Document()
    
    enum CodingKeys: String, CodingKey {
        case id, _id, user, Author
        case title, mimiType = "content_type"
        case createdAt = "created_at"
        case hash, filename
        case scope, tags, stickers
        case smeDocumentId = "SMEDocumentID"
        case path = "path"
        case oneDriveItemId = "oneDriveItemID"
        case oneDrivePath = "oneDrivePath"
    }
    
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(
            id: (try? container.decode(String.self, forKey: .id)).as((try? container.decode(String.self, forKey: ._id)).as(.default)),
            user: (try? container.decode(String.self, forKey: .user)).as((try? container.decode(String.self, forKey: .Author)).as(.default)),
            title: try container.decode(String.self, forKey: .title),
            mimiType: MimeType(rawValue: try container.decode(String.self, forKey: .mimiType)).as(.unknown),
            filename: try container.decode(String.self, forKey: .filename),
            createdAt: (try container.decode(String.self, forKey: .createdAt)).date.as(.default),
            hash: try container.decode(String.self, forKey: .hash),
            scope: Scope(rawValue: (try? container.decode(String.self, forKey: .scope)).as(.default)).as(.none),
            tags: (try? container.decode([String].self, forKey: .tags)).as(.default).map({ Tag(tag: $0) }),
            stickers: (try? container.decode([String].self, forKey: .stickers)).as(.default).map({ Sticker(name: $0) }),
            path: try? container.decode(String.self, forKey: .path),
            smeDocumentId: try? container.decode(String.self, forKey: .smeDocumentId),
            oneDriveItemId: try? container.decode(String.self, forKey: .oneDriveItemId),
            oneDrivePath: try? container.decode(String.self, forKey: .oneDrivePath)
        )
    }
    
    init(id: String = .default,
         user: String = .default,
         title: String = .default,
         mimiType: MimeType = .unknown,
         filename: String = .default,
         createdAt: Date = .default,
         hash: String = .default,
         scope: Scope = .none,
         tags: [Tag] = .default,
         stickers: [Sticker] = .default,
         path: String? = .none,
         smeDocumentId: String? = .none,
         oneDriveItemId: String? = .none,
         oneDrivePath: String? = .none) {
        self.id = id
        self.user = user
        self.title = title
        self.mimiType = mimiType
        self.filename = filename
        self.createdAt = createdAt
        self.hash = hash
        self.scope = scope
        self.tags = tags
        self.stickers = stickers
        
        self.path = path
        self.localFilePath = String(format: "%@.%@", self.hash, self.mimiType.pathExtension)
        self.localFileURL = .default
        self.data = .default
        self.thumbnail = .none

        self.smeDocumentId = smeDocumentId
        self.oneDriveItemId = oneDriveItemId
        self.oneDrivePath = oneDrivePath
        
        self.hasRelatedGFADocument = self.smeDocumentId.notNil
        self.hasRelatedOneDriveDocument = self.oneDriveItemId.notNil
        self.isOneDriveDocument = (!self.hasRelatedOneDriveDocument && self.oneDrivePath.notNil)
        
        self.needGFA = (!self.isOneDriveDocument || self.hasRelatedGFADocument)
        self.needOneDrive = (self.isOneDriveDocument || self.hasRelatedOneDriveDocument)
        
        self.oneDriveTitle = self.oneDrivePath.as(.default)
            .remove(of: "GFA")
            .appending(self.title)
        
        self.isOwnDocument = (self.user.lowercased() == SMESettingsManager()?.user.name.lowercased())
    }
    
    /*
    init?(_ info: [AnyHashable: Any]) {
        guard
            let properties = info["properties"] as? [AnyHashable: Any],
            let author = properties["Author"] as? String,
            let mimiType = info["type"] as? String,
            let filename = info["filename"] as? String,
            let createdAt = info["added"] as? Date,
            let scope = info["scope"] as? String,
            let stickersInfo = info["stickers"] as? Array<[AnyHashable: Any]> else { return nil }
        
        self.init(
            user: author,
            mimiType: MimeType(rawValue: mimiType).as(.none),
            filename: filename,
            createdAt: createdAt,
            scope: Scope(rawValue: scope).as(.none),
            stickers: stickersInfo.map({ Sticker($0) }),
            smeDocumentId: info["SMEDocumentID"] as? String,
            oneDriveItemId: info["oneDriveItemID"] as? String,
            oneDrivePath: info["oneDrivePath"] as? String
        )
    }
     */
    
    static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Document, rhs: Document) -> Bool {
        var res: Bool
        switch SMEDataManager.shared.documentListSortingField {
        case .author:
            res = lhs.user < rhs.user
        case .added:
            res =  lhs.createdAt < rhs.createdAt
        case .title:
            res = lhs.title < rhs.title
        case .type:
            res = lhs.mimiType.shortType < rhs.mimiType.shortType
        }
        return SMEDataManager.shared.documentsListSortAscending ? res : !res
    }
}
