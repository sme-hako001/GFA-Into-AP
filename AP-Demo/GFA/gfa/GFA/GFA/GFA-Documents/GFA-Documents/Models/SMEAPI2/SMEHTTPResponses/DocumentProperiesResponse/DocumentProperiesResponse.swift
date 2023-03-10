//
//  DocumentProperiesResponse.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/2/23.
//

struct DocumentProperiesResponse: SMEHTTPResponseV3 {
    typealias DataType = Document
    
    var data: DataType!
    var meta: Status
}
