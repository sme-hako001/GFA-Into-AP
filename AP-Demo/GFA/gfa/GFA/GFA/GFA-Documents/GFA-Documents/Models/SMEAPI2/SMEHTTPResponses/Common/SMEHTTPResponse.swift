//
//  SMEHTTPResponse.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/24/23.
//

protocol SMEHTTPResponse: Decodable {
    associatedtype DataType
    
    var data: DataType! { get }
    var status: Status { get }
}

protocol SMEHTTPResponseV3: Decodable {
    associatedtype DataType
    
    var data: DataType! { get }
    var meta: Status { get }
}
