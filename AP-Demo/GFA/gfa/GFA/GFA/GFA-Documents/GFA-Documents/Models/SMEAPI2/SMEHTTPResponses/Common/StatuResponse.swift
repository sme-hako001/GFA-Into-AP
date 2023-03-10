//
//  StatuResponse.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/24/23.
//

struct StatuResponse: Decodable {
    let status: Status
    
    
    enum CodingKeys: String, CodingKey {
        case status, meta
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.status = (try? container.decode(Status.self, forKey: .status)).as(
            (try? container.decode(Status.self, forKey: .meta)).as(.default)
        )
    }
}
