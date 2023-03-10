//
//  ValidateTokenResponse.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/24/23.
//

struct ValidateTokenResponse: SMEHTTPResponse {    
    typealias DataType = UserGFA
    
    var data: DataType!
    var status: Status
}
