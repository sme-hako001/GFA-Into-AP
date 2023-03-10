//
//  IURLSessionDocumentDelegate.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/14/23.
//

import Foundation

protocol IURLSessionDocumentDelegate: AnyObject {
    func didStartDocumentPreload(_ title: String?, _ size: Int64)
    func didReceiveDocumentPreload(_ size: Int)
    
    func didStartDocumentDownload(_ documentURL: URL, _ size: Int64)
    func didReceiveDocumentDownload(_ documentURL: URL, _ size: Int)
    func didFinishDocumentDownload(_ documentURL: URL, _ documentData: Data)
    func didFailDocumentDownload(_ documentURL: URL, _ error: SMEAPI2._Error!)
    
    func didStartDocumentUpload(_ documentURL: URL)
    func didFinishDocumentUpload(_ documentURL: URL)
    func didFailDocumentUpload(_ documentURL: URL, _ error: SMEAPI2._Error!)
}
