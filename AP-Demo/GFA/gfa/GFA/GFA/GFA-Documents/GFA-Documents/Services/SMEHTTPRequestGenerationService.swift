//
//  SMEHTTPRequestGenerationService.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/13/23.
//

import Foundation

final
class SMEHTTPRequestGenerationService {
    private let settingsManager: SMESettingsManager = SMESettingsManager()!
    private var smeRequestData: SMERequestData! = .none
    
    
    func generate(_ smeRequestData: SMERequestData) -> SMEHTTPRequest {
        self.smeRequestData = smeRequestData
        
        let smeHTTPRequest = SMEHTTPRequest(requestData: self.smeRequestData,
                                            parsingType: self.parsingType,
                                            url: self.url,
                                            noTokenURL: self.noTokenURL,
                                            httpMethod: self.httpMethod,
                                            allHTTPHeaderFields: self.allHTTPHeaderFields,
                                            httpBody: self.httpBody)
        
        return smeHTTPRequest
    }

    
    // MARK: - Private Implementation -
    
    private var url: URL {
        URL(string: self.urlString)!
    }
    
    private var noTokenURL: URL! {
        switch self.smeRequestData.type {
        case .document:
            return URL(string:
                        SMEStringUtils.percentEncodedURLString(
                            self.coverURLString
                        )
            )!
        default:
            return self.url
        }
    }
    
    private var urlString: String {
        String(format: "%@%@",
               self.settingsManager.basicURL,
               self.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
    }
    
    private var coverURLString: String {
        switch self.smeRequestData.type {
        case .document: return
            String(format: "%@/download/[token]%@",
                                      self.settingsManager.basicURL,
                                      self.smeRequestData.filePath)
        default: return .default
        }
    }
    
    private var path: String {
        switch self.smeRequestData.type {
        case .login: return "/login"
        case .validateToken: return "/v1/me"
        case .documentsList: return "/v1/documents/available"
        case .document: return "/download/\((self.settingsManager.credentials?.token).as(.default))\(self.smeRequestData.filePath)"
        case .documentProperties: return "/v3/documents/\(self.smeRequestData.documentId)"
        case .documentRemove: return "/v1/documents/delete"
        case .documentModify: return "/v1/documents/modify"
        case .documentTags: return "/v1/documents/tags"
        case .documentStickers: return "/v1/documents/stickers"
        default: return .default
        }
    }
    
    private var queryItems: [URLQueryItem] {
        switch self.smeRequestData.type {
        case .documentsList: return  [
            URLQueryItem(name: "format_version",
                         value: self.settingsManager.formatVersionOfDocumentsAvailable)
        ]
        default: return .default
        }
    }
    
    private var httpMethod: String {
        switch self.smeRequestData.type {
        case .login,
                .documentRemove,
                .documentModify: return "POST"
        case .validateToken,
                .documentsList,
                .document,
                .documentProperties,
                .documentTags,
                .documentStickers: return "GET"
        default: return .default
        }
    }
    
    private var allHTTPHeaderFields: [String: String] {
        switch self.smeRequestData.type {
        case .login: return [
            "charset": "UTF-8"
        ]
        case .validateToken,
                .documentsList,
                .documentRemove,
                .documentProperties,
                .documentModify,
                .documentTags,
                .documentStickers: return [
                    "charset": "UTF-8",
                    "token-type": "Bearer",
                    "access-token": (self.settingsManager.credentials?.token).as(.default),
                ]
        default: return .default
        }
    }
    
    private var httpBody: Data? {
        switch self.smeRequestData.type {
        case .login: return String(format: "username=%@&password=%@",
                                   SMEStringUtils.percentEncodedURLString((self.settingsManager.credentials?.login).as(.default)),
                                   SMEStringUtils.percentEncodedURLString((self.settingsManager.credentials?.password).as(.default))).data
        case .documentRemove: return "id=\(self.smeRequestData.documentId)".data
        case .documentModify: return self.smeRequestData.documentPropertiesToChange.queryString.data
        default: return .none
        }
    }
    
    private var parsingType: SMERequestParsingType {
        switch self.smeRequestData.type {
        case .login,
                .validateToken,
                .documentsList,
                .documentRemove,
                .documentProperties,
                .documentModify,
                .documentTags,
                .documentStickers: return .JSON
        default: return .noParsing
        }
    }
}
