//
//  DocumentsListResponse.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/28/23.
//

struct DocumentsListResponse: SMEHTTPResponse {
    typealias DataType = DocumentsListData
    
    var data: DataType!
    var status: Status
}
