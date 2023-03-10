//
//  SMERequestData.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/6/23.
//

import Foundation

struct SMERequestData {
    let preloadRequest: Bool
    let forceLoad: Bool
    let useShortTimeout: Bool
    let type: SMERequestType
    let timestamp: TimeInterval?
    let sheetId: String
    let coverURL: String
    let dcgenIdsDictionary: [String: Any]
    let dcgenId: String
    let projectId: Int
    let responseType: SMERequestResponseType
    let regionDrilldownIdsArray: [Any]
    let periodIdsArray: [Any]
    let customerId: String
    let metricId: String
    let pathExtension: String
    let documentId: String
    let filePath: String
    let documentPropertiesToChange: [String: Any]
    let uploadTargetName: String
    let uploadSourceURL: URL
    let uploadSourceMediaType: String
    let oneDriveItemId: String?
    
    
    init(preloadRequest: Bool = .default,
         forceLoad: Bool = .default,
         useShortTimeout: Bool = .default,
         type: SMERequestType = .login,
         timestamp: TimeInterval? = .none,
         sheetId: String = .default,
         coverURL: String = .default,
         dcgenIdsDictionary: [String: Any] = .default,
         dcgenId: String = .default,
         projectId: Int = .default,
         responseType: SMERequestResponseType = .SMERRT_REGIONS,
         regionDrilldownIdsArray: [Any] = .default,
         periodIdsArray: [Any] = .default,
         customerId: String = .default,
         metricId: String = .default,
         pathExtension: String = .default,
         documentId: String = .default,
         filePath: String = .default,
         documentPropertiesToChange: [String: Any] = .default,
         uploadTargetName: String = .default,
         uploadSourceURL: URL = .default,
         uploadSourceMediaType: String = .default) {
        self.preloadRequest = preloadRequest
        self.forceLoad = forceLoad
        self.useShortTimeout = useShortTimeout
        self.type = type
        self.timestamp = timestamp
        self.sheetId = sheetId
        self.coverURL = coverURL
        self.dcgenIdsDictionary = dcgenIdsDictionary
        self.dcgenId = dcgenId
        self.projectId = projectId
        self.responseType = responseType
        self.regionDrilldownIdsArray = regionDrilldownIdsArray
        self.periodIdsArray = periodIdsArray
        self.customerId = customerId
        self.metricId = metricId
        self.pathExtension = pathExtension
        self.documentId = documentId
        self.filePath = filePath
        self.documentPropertiesToChange = documentPropertiesToChange
        self.uploadTargetName = uploadTargetName
        self.uploadSourceURL = uploadSourceURL
        self.uploadSourceMediaType = uploadSourceMediaType
        self.oneDriveItemId = .none
    }
}
