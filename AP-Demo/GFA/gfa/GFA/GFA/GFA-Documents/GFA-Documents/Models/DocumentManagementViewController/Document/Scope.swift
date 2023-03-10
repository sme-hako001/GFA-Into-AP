//
//  Scope.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/2/23.
//

enum Scope: String, Codable {
    case none
    case `private`
    case protected
    case `public`
    
    static let allCases: [Scope] = [
        .private,
        .protected,
        `public`
    ]
    
    var index: Int {
        switch self {
        case .none: return -1
        case .private: return 0
        case .protected: return 1
        case .public: return 2
        }
    }
    
    
    init(index: Int) {
        switch index {
        case Scope.private.index: self = .private
        case Scope.protected.index: self = .protected
        case Scope.public.index: self = .public
        default:  self = .none
        }
    }
}
