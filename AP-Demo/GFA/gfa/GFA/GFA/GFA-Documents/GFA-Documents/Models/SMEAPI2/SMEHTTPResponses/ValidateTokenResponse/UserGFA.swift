//
//  UserGFA.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/24/23.
//

struct UserGFA: Codable {
    let actions: [Action]
    let expireAfter: Int
    let lifetime: Int
    let name: String
    let stickers: [String]
    let token: String
    
    
    private enum CodingKeys: String, CodingKey {
        case actions, expireAfter, lifetime
        case name, stickers, token
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.actions = ((try? values.decode([String].self, forKey: .actions))?
            .compactMap({ Action(rawValue: $0) })).as(.default)
        self.expireAfter = (try? values.decode(Int.self, forKey: .expireAfter)).as(.default)
        self.lifetime = (try? values.decode(Int.self, forKey: .lifetime)).as(.default)
        self.name = (try? values.decode(String.self, forKey: .name)).as(.default)
        self.stickers = (try? values.decode([String].self, forKey: .stickers)).as(.default)
        self.token = (try? values.decode(String.self, forKey: .token)).as(.default)
    }
}
