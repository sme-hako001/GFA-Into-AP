//
//  URLSessionConfiguration+SME.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/9/23.
//

import Foundation

extension URLSessionConfiguration {
    static func sem(_ timeoutIntervalForRequest: TimeInterval) -> URLSessionConfiguration {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = timeoutIntervalForRequest
        
        return sessionConfiguration
    }
}
