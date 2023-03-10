//
//  SMEHTTPRequest.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/3/23.
//

import Foundation

class SMEHTTPRequest: NSMutableURLRequest {
    var requestData: SMERequestData
    let additionalRequestData: SMERequestData!
    let cacheable: Bool
    var parsingType: SMERequestParsingType
    let token: String!
    var noTokenURL: URL
    let responseDictionary: [String: Any]!
    var responseData: Data
    let responseFilePath: String!
    let temporaryDecryptedFilePath: String!
    let encryptor: RNEncryptor!
    var responseSize: Int!
    var responseStatusCode: Int!
    var responseStatusMessage: String!
    var error: SMEAPI2._Error!
    let theConnection: NSURLConnection!
    var delegate: Any?
    let didReceiveResponseSelector: Selector!
    let didReceiveSomeDataSelector: Selector!
    
    
    init(requestData: SMERequestData,
         parsingType: SMERequestParsingType,
         url: URL,
         noTokenURL: URL,
         httpMethod: String,
         allHTTPHeaderFields: [String: String],
         httpBody: Data?) {
        self.additionalRequestData = .none
        self.cacheable = false
        self.token = .none
        self.responseDictionary = .none
        self.responseData = .default
        self.responseFilePath = .none
        self.temporaryDecryptedFilePath = .none
        self.encryptor = .none
        self.responseSize = .none
        self.responseStatusCode = .none
        self.responseStatusMessage = .none
        self.error = .none
        self.theConnection = .none
        self.delegate = .none
        self.didReceiveResponseSelector = .none
        self.didReceiveSomeDataSelector = .none
        
        self.requestData = requestData
        self.parsingType = parsingType
        self.noTokenURL = noTokenURL
        
        super.init(url: url,
                   cachePolicy: .useProtocolCachePolicy,
                   timeoutInterval: 60)
        
        self.httpMethod = httpMethod
        self.allHTTPHeaderFields = allHTTPHeaderFields
        self.httpBody = httpBody
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods -
    
    func addData(_ data: Data) {
        switch self.responseFilePath.isNil {
        case true: self.responseData.append(data)
        case false: self.encryptor.addData(data)
        }
    }
    
    func finishEncryptionIfNeeded() {
        guard self.responseFilePath.notNil else { return }
        
        self.encryptor.finish()
    }
}
