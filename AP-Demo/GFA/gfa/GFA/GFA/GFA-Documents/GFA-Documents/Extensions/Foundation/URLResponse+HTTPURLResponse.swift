//
//  URLResponse+HTTPURLResponse.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/15/23.
//

import Foundation

extension URLResponse {
    var httpStatusCode: Int? {
        self.asHTTPURLResponse?.statusCode
    }
    
    var statusCodeDescription: String? {
        guard let statusCode = self.httpStatusCode else { return .none }
        
        let statusCodeDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        
        return statusCodeDescription
    }
    
    private var asHTTPURLResponse: HTTPURLResponse? {
        (self as? HTTPURLResponse)
    }
}
