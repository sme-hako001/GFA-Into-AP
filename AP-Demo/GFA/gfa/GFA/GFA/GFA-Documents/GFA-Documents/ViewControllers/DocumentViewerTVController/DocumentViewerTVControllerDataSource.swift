//
//  DocumentViewerTVControllerDataSource.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/20/23.
//

protocol DocumentViewerTVControllerDataSource: AnyObject {
    var isSearchInProgress: Bool { get }
    var documentListForceUpdateMessage: String? { get }
    var currentRequestError: IErrorCode? { get }
}
