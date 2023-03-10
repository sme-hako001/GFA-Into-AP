//
//  Credentials.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/24/23.
//

struct Credentials: Codable {
    let login: String?
    let password: String?
    let token: String?
    
    
    init(login: String? = .none,
         password: String? = .none,
         token: String? = .none) {
        self.login = login
        self.password = password
        self.token = token
    }
}
