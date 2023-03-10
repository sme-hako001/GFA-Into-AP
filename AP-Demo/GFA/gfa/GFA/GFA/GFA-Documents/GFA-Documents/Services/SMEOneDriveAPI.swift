//
//  SMEOneDriveAPI.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/23/23.
//

import Foundation
import UIKit

final
class SMEOneDriveAPI {
    private let settingsManager: SMESettingsManager = SMESettingsManager()!
    private let requestGenerationService: SMEHTTPRequestGenerationService = SMEHTTPRequestGenerationService()
    private let cacheVerifyManager: SMECacheVerifyManager = SMECacheVerifyManager.shared
    private let accessToken: String?
    private let refreshToken: String?
    
    private(set) lazy var needOneDrive: Bool = (self.isLoggedIn() || self.isDataPreloadedForDocumentsList())
    
    static let shared: SMEOneDriveAPI = SMEOneDriveAPI()
    
    
    private init() {
        self.accessToken = .none
        self.refreshToken = .none
    }
    
    
    // MARK: - Methods -
    
    func isLoggedIn() -> Bool {
        (self.accessToken.notNil && self.refreshToken.notNil)
    }
    
    func isDataPreloadedForDocumentsList() -> Bool {
        self.isDataPreloaded(
            SMERequestData(type: .oneDriveDocumentList)
        )
    }
    
    func isDataPreloadedForDocument(_ documentId: String) -> Bool {
        self.isDataPreloaded(
            SMERequestData(
                type: .oneDriveDocument,
                coverURL: self.getDownloadURLForDocuemnt(documentId)
            )
        )
    }
    
    
    // MARK: - Private Implementation -
    
    private func isDataPreloaded(_ smeRequestData: SMERequestData) -> Bool {
        self.cacheVerifyManager.canUseCachedData(
            self.requestGenerationService.generate(smeRequestData)
        )
    }
    
    private func getDownloadURLForDocuemnt(_ documentId: String) -> String {
        String(format: "%@/drive/items/%@/content", self.settingsManager.basicURL, documentId)
    }
}
