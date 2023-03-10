//
//  Status.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/9/23.
//

struct Status: Decodable {
    let code: Int
    let message: String?
    
    static let `default` = Status()
    
    enum CodingKeys: CodingKey {
        case code, message
    }
    
    
    init(code: Int = .default,
         message: String? = .none) {
        self.code = code
        self.message = message
    }
    
    init( decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(Int.self, forKey: .code)
        self.code = (code.isZero ? 500 : code)
        self.message = try container.decode(String?.self, forKey: .message)
    }
}
