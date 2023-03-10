//
//  SMEAPI2.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/3/23.
//

import Foundation
import UIKit

final
class SMEAPI2: NSObject {
    private let requestGenerationService: SMEHTTPRequestGenerationService = SMEHTTPRequestGenerationService()
    private let errorManager: SMEErrorManager = SMEErrorManager.shared
    private let dataManager: SMEDataManager = SMEDataManager.shared
    private let cacheVerifyManager: SMECacheVerifyManager = SMECacheVerifyManager.shared
    private let macrosInfoProvider: MacrosInfoProvider = MacrosInfoProvider()
    private let settingsManager: SMESettingsManager = SMESettingsManager()!
    private let requestQueue: DispatchQueue = DispatchQueue(label: "com.sonymusic.request")
    private let semaphoreQueue: DispatchQueue = DispatchQueue(label: "com.sonymusic.semaphore")
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 5)
    private var timestamps: [SMERequestType: TimeInterval] = .default
    private var activeDownloadRequests: [URL: SMEHTTPRequest] = .default
    private var currentPreloadTimestamp: TimeInterval = TimeInterval()
    private var currentDocumentTimestamp: TimeInterval = 10
    
    weak var documentDelegate: IURLSessionDocumentDelegate? = .none
    
    static let shared: SMEAPI2 = SMEAPI2()
    
    indirect
    enum _Error: Error, IErrorCode {
        case requestCanceledReasonIsInvalidTimestamp
        case useCacheResponseFail(_ reason: SMECacheVerifyManager._Error)
        case decodingFail(_ error: Error)
        case instanceNotFound
        case requestFailed(_ data: Data?, _ response: URLResponse?, _ error: Error?)
        case forceRegistrationError400
        case cacheFail(_ reason: SMECacheVerifyManager._Error)
        case forbiddenError403(_ message: String)
        case serverError(_ status: Status?)
        case internetOrVPNConnectionIsNotDetected
        case noPermissionsToBeAuthorised
        case newTokenRetrievalFailed
        case didReceiveDataFailTokenExpired
        case didReceiveDataFail(_ code: Int)
        case didCompleteWithError(_ error: Error?, _ code: Int? = .none)
        case didBecomeInvalid(_ error: Error?)
        
        var code: Int {
            switch self{
            case .requestFailed: return 2026
            case .forbiddenError403: return 2027
            case .forceRegistrationError400: return 2028
            case .serverError(.some(let status)) where status.code < 1000: return 2028
            case .serverError(.some(let status)): return status.code
            case .internetOrVPNConnectionIsNotDetected: return 2006
            case .noPermissionsToBeAuthorised: return 2049
            case .newTokenRetrievalFailed: return 2008
            case .didReceiveDataFailTokenExpired: return 2008
            case .didReceiveDataFail(let code): return code
            case .didCompleteWithError(_, .some(let code)): return code
            default: return 0
            }
        }
    }
    
    
    private override init() {
        
    }
    
    
    // MARK: - Methods -
    
    func validateToken(_ token: String, completion: @escaping (Result<ValidateTokenResponse, _Error>) -> Void) {
        self.makeRequest(
            self.requestGenerationService.generate(
                SMERequestData(type: .validateToken,
                               timestamp: self.makeTimestamp(.validateToken)
                              )
            ),
            completion
        )
    }
    
    func getDocumentsList(completion: @escaping (Result<DocumentsListResponse, _Error>) -> Void) {
        self.makeRequest(
            self.requestGenerationService.generate(
                SMERequestData(type: .documentsList,
                               timestamp: self.makeTimestamp(.documentsList)
                              )
            ),
            completion
        )
    }
    
    func getDocumentProperties(_ documentId: String, _ completion: @escaping (Result<DocumentProperiesResponse, _Error>) -> Void) {
        self.makeRequest(
            self.requestGenerationService.generate(
                SMERequestData(type: .documentProperties,
                               timestamp: self.makeTimestamp(.documentProperties),
                               documentId: documentId
                              )
            ),
            completion
        )
    }
    
    func downloadDocument(_ filePath: String) {
        let completion: (Result<StatuResponse, _Error>) -> Void = { _ in }
        
        self.makeRequest(
            self.requestGenerationService.generate(
                SMERequestData(type: .document,
                               timestamp: self.makeTimestamp(.document),
                               filePath: filePath
                              )
            ),
            completion
        )
    }
    
    func removeDocument(_ documentId: String, _ completion: @escaping (Result<_Void, _Error>) -> Void) {
        self.makeRequest(
            self.requestGenerationService.generate(
                SMERequestData(type: .documentRemove,
                               timestamp: self.makeTimestamp(.documentRemove),
                               documentId: documentId
                              )
            ),
            completion
        )
    }
    
    func modifyDocument(_ documentId: String, _ documentPropertiesToChange: [String: Any], _ completion: @escaping (Result<Document, _Error>) -> Void) {
        self.makeRequest(
            self.requestGenerationService.generate(
                SMERequestData(type: .documentModify,
                               timestamp: self.makeTimestamp(.documentModify),
                               documentId: documentId,
                               documentPropertiesToChange: documentPropertiesToChange
                              )
            ),
            completion
        )
    }
    
    func getDocumentTags(_ documentId: String, _ completion: @escaping (Result<_Void, _Error>) -> Void) {
        self.makeRequest(
            self.requestGenerationService.generate(
                SMERequestData(type: .documentTags,
                               timestamp: self.makeTimestamp(.documentTags),
                               documentId: documentId
                              )
            ),
            completion
        )
    }
    
    func getDocumentStickers(_ documentId: String, _ completion: @escaping (Result<_Void, _Error>) -> Void) {
        self.makeRequest(
            self.requestGenerationService.generate(
                SMERequestData(type: .documentStickers,
                               timestamp: self.makeTimestamp(.documentStickers),
                               documentId: documentId
                              )
            ),
            completion
        )
    }
    
    
    // MARK: - Private Implementation -
    
    private func makeRequest<T: Decodable>(_ smeHTTPRequest: SMEHTTPRequest, _ completion: @escaping (Result<T, _Error>) -> Void) {
        self.semaphoreQueue.async {
            _ = self.semaphore.wait(timeout: .distantFuture)
            
            self.requestQueue.async {
                guard self.validateTimestamp(smeHTTPRequest, completion) else { return }
                
                self.errorManager.reset()
                
                self.performBase(smeHTTPRequest, completion)
            }
        }
    }
    
    private func makeTimestamp(_ smeRequestType: SMERequestType) -> TimeInterval {
        let timestamp = self.timestamps[smeRequestType].as(Date().timeIntervalSince1970)
        
        self.timestamps[smeRequestType] = timestamp
        
        return timestamp
    }
    
    private func validateTimestamp<T>(_ smeHTTPRequest: SMEHTTPRequest, _ completion: @escaping (Result<T, _Error>) -> Void) -> Bool {
        guard self.timestamps[smeHTTPRequest.requestData.type] != smeHTTPRequest.requestData.timestamp else { return true }
        
        async { [weak self] in
            completion(.failure(.requestCanceledReasonIsInvalidTimestamp))
            
            self?.semaphore.signal()
        }
        
        return false
    }
    
    private func performBase<T: Decodable>(_ smeHttpRequest: SMEHTTPRequest, _ completion: @escaping (Result<T, _Error>) -> Void) {
        self.perform(smeHttpRequest) { [weak self] result in
            self?.requestQueue.async {
                guard (self?.validateTimestamp(smeHttpRequest, completion)).as(false) else { return }
                
                async {
                    switch result {
                    case .success(let data):
                        switch ((self?.makeExpectedResult(data)).as(.failure(.instanceNotFound)) as Result<T, _Error>) {
                        case .success(let expectedResult): completion(.success(expectedResult))
                        case .failure(let error): completion(.failure(error))
                        }
                    case .failure(let error):
                        if case .forceRegistrationError400 = error {
                            GFACoordinator.shared.performPasswordConfirmationRequest();
                        }
                        
                        completion(.failure(error))
                    }
                    
                    self?.semaphore.signal()
                }
            }
        }
    }
    
    private func perform(_ smeHttpRequest: SMEHTTPRequest, _ completion: @escaping (Result<Data, _Error>) -> Void) {
        switch (smeHttpRequest.requestData.type,
                smeHttpRequest.requestData.forceLoad,
                smeHttpRequest.parsingType != .customTransform,
                self.cacheVerifyManager.canUseCachedData(smeHttpRequest)) {
        case (_, false, true, true): self.performCacheResponse(smeHttpRequest, completion)
        case (.document, _, _, _): self.performURLSessionResponseForDownload(smeHttpRequest)
        default: self.performURLSessionResponse(smeHttpRequest, completion)
        }
    }
    
    private func performCacheResponse(_ smeHttpRequest: SMEHTTPRequest, _ completion: (Result<Data, _Error>) -> Void) {
        self.cacheVerifyManager.useCacheResponse(smeHttpRequest, { result in
            switch result {
            case .success(let data): completion(.success(data))
            case .failure(let cacheError): completion(.failure(.useCacheResponseFail(cacheError)))
            }
        })
    }
    
    private func performURLSessionResponseForDownload(_ smeHttpRequest: SMEHTTPRequest) {
        self.activeDownloadRequests[smeHttpRequest.url.as(.default)] = smeHttpRequest
        
        self.performURLSessionResponse(smeHttpRequest)
        
    }
    
    private func performURLSessionResponse(_ smeHttpRequest: SMEHTTPRequest) {
        URLSession(configuration: .sem(self.getTimeout(smeHttpRequest.requestData.useShortTimeout)),
                   delegate: self,
                   delegateQueue: .main)
        .dataTask(with: smeHttpRequest as URLRequest)
        .resume()
    }
    
    private func performURLSessionResponse(_ smeHttpRequest: SMEHTTPRequest, _ completion: @escaping (Result<Data, _Error>) -> Void) {
        URLSession(configuration: .sem(self.getTimeout(smeHttpRequest.requestData.useShortTimeout)),
                   delegate: self,
                   delegateQueue: .main)
        .dataTask(with: smeHttpRequest as URLRequest) { data, response, error in
            DispatchQueue.global(qos: .default).async {
                
                let completeURLSession: (Result<Data, _Error>) -> Void = { result in
                    async {
                        completion(result)
                    }
                }
                
                guard
                    let data = data,
                    error.isNil else {
                    completeURLSession(.failure(.requestFailed(data, response, error)))
                    
                    return
                }
                
                smeHttpRequest.responseData = data
                smeHttpRequest.responseSize = data.count
                
                let statusResponse = try? JSONDecoder().decode(StatuResponse.self, from: data)
                
                switch (smeHttpRequest.parsingType,
                        statusResponse?.status.code,
                        smeHttpRequest.requestData.type) {
                case (_, 200, _):
                    self.cacheIfNeeded(smeHttpRequest, completeURLSession)
                    // FIXME: - We need make final decision about _OKTA_AUTH/SMERT_LOGOUT-
                    // internetOrVPNConnectionIsNotDetected, noPermissionsToBeAuthorised, newTokenRetrievalFailed, forceRegistrationError400
//                case (_, 401, _, true),
//                    (_, 417, _, true):
//                    break
                case (_, 401, _),
                    (_, 417, _):
                    async {
                        GFACoordinator.shared.start(cleanCredentials: true)
                    }
                case (_, 403, _):
                    completeURLSession(.failure(.forbiddenError403("alertNoPermissionsTitle".localized)))
                default:
                    completeURLSession(.failure(.serverError(statusResponse?.status)))//.as("requestFailedServerErrorMessage".localized))))
                }
            }
        }
        .resume()
    }
    
    private func cacheIfNeeded(_ smeHTTPRequest: SMEHTTPRequest, _ completion: @escaping (Result<Data, _Error>) -> Void) {
        switch smeHTTPRequest.cacheable {
        case true: self.cache(smeHTTPRequest, completion)
        case false: completion(.success(smeHTTPRequest.responseData))
        }
    }
    
    private func cache(_ smeHTTPRequest: SMEHTTPRequest, _ completion: @escaping (Result<Data, _Error>) -> Void) {
        self.cacheVerifyManager.cache(smeHTTPRequest, { result in
            completion(.success(smeHTTPRequest.responseData))
        })
    }
    
#if _OKTA_AUTH
    private func performURLSession(_ smeHttpRequest: SMEHTTPRequest,
                                   _ token: String,
                                   _ performSessionKeepalive: Bool,
                                   _ completion: (Result<Any, SMEAPI2_Error>) -> Void) {
        
    }
#endif
    
    private func makeExpectedResult<T: Decodable>(_ data: Data) -> Result<T, _Error> {
        let result: Result<T, _Error>
        
        do {
            let expectedResult = try JSONDecoder().decode(T.self, from: data)
            
            result = .success(expectedResult)
        } catch {
            result = .failure(.decodingFail(error))
        }
        
        return result
    }
    
    private func getTimeout(_ useShortTimeout: Bool) -> TimeInterval {
        (useShortTimeout
         ? SHORT_REQUEST_TIMEOUT_INTERVAL
         : (self.macrosInfoProvider.is(._SME_TEST_VERSION)
            ? 60
            : 20))
    }
    
    private func signalSemaphore(_ count: UInt) {
        (UInt.one...count).forEach({ _ in
            self.semaphore.signal()
        })
    }
}


// MARK: - SMEAPI2+URLSessionDataDelegate -

extension SMEAPI2: URLSessionDataDelegate {
    
    // MARK: - URLSessionDelegate -
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        ConsoleProvider().printError(#function, error.as(_Error.didBecomeInvalid(error)))
    }
    
    /*
     func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
     // Get Server Certificate Chain
     guard
     let serverTrust = challenge.protectionSpace.serverTrust,
     let serverCertificateChain = SecTrustCopyCertificateChain(serverTrust),
     let serverCertificateUnsafePointer = CFArrayGetValueAtIndex(serverCertificateChain, .zero) else {
     completionHandler(.cancelAuthenticationChallenge, .none)
     
     return
     }
     
     // Set SSL Policies For Domain Name Check
     let policies: CFTypeRef = [
     SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
     ] as AnyObject
     SecTrustSetPolicies(serverTrust, policies)
     
     // Evaluate Server Certificate
     let certificateIsTrusted = SecTrustEvaluateWithError(serverTrust, .none)
     
     // Get Server Certificate Data
     let serverCertificate = unsafeBitCast(serverCertificateUnsafePointer, to: SecCertificate.self)
     let serverCertificateCFData = SecCertificateCopyData(serverCertificate)
     let serverCertificateData = Data(cfData: serverCertificateCFData)
     
     var clientCertificateData: Data? = .none
     
     let clientHostings = [
     "cloudfront.net",
     "release.smecde.com",
     "images.unsplash.com"
     ]
     
     clientHostings.forEach({ clientHost in
     if challenge.protectionSpace.host.contains(clientHost),
     let certificateData = clientHost.certificateURL?.data {
     clientCertificateData = certificateData
     }
     })
     
     if clientCertificateData.isNil {
     clientCertificateData = self.settingsManager.certifcateNameSSL.certificateURL?.data
     }
     
     let clientServerCertificatesMatches = (clientCertificateData == serverCertificateData)
     
     // The Pinnning Check
     switch (certificateIsTrusted, clientServerCertificatesMatches) {
     case (true, true):
     completionHandler(.useCredential, URLCredential(trust: serverTrust))
     default:
     completionHandler(.cancelAuthenticationChallenge, .none)
     }
     }
     */
    
    
    // MARK: - URLSessionTaskDelegate -
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        ConsoleProvider().printError(#function, error.as(_Error.didCompleteWithError(error)))
        
        let url: URL! = (task.currentRequest?.url).asOptional(task.taskDescription?.url)
        
        defer {
            self.activeDownloadRequests.removeValue(forKey: url.as(.default))
            
            session.invalidateAndCancel()
        }
        
        guard
            url.notNil,
            let smeHTTPRequest = self.activeDownloadRequests[url] else { return }
        
        let signalSemaphoreOnceAndMore: () -> Void = {
            //[[SMEDataManager sharedInstance] processFailedRequest:aRequest];
            
            self.signalSemaphore(1)
        }
        
        let signalSemaphoreOnceAndMoreAndSetError: (_Error) -> Void = { error in
            self.errorManager.setError(error)
            
            smeHTTPRequest.error = error
            //[[SMEDataManager sharedInstance].serverErrorHandler logErrorWithCode:aRequest.error.code paramsArray:nil];
            
            signalSemaphoreOnceAndMore()
        }
        
        let signalSemaphoreOnceAndMoreAndSetErrorAndFinish: (_Error) -> Void = { error in
            signalSemaphoreOnceAndMoreAndSetError(error)
            
            //[[SMEDataManager sharedInstance] processFinishedDocumentRequest:aRequest];
        }
        
        let signalSemaphoreOnceAndMoreAndSetErrorAndFinishAndMore: (_Error) -> Void = { error in
            signalSemaphoreOnceAndMoreAndSetErrorAndFinish(error)
            
            self.signalSemaphore(4)
        }
        
        switch (task.response,
                smeHTTPRequest.requestData.type,
                smeHTTPRequest.requestData.preloadRequest) {
        case (.none, .document, true):
            signalSemaphoreOnceAndMoreAndSetErrorAndFinishAndMore(.didCompleteWithError(error, 2035))
        case (.none, .document, false):
            signalSemaphoreOnceAndMoreAndSetErrorAndFinish(.didCompleteWithError(error, 2032))
        case (.none, .documentUpload, true):
            signalSemaphoreOnceAndMoreAndSetError(.didCompleteWithError(error, 2035))
        case (.none, .documentUpload, false):
            signalSemaphoreOnceAndMoreAndSetError(.didCompleteWithError(error, 2032))
        case (.none, _, _):
            signalSemaphoreOnceAndMore()
        default:
            break
        }
        
        switch (smeHTTPRequest.error,
                smeHTTPRequest.requestData.type) {
        case (.some(let error), .documentUpload):
            self.documentDelegate?.didFailDocumentUpload(smeHTTPRequest.requestData.uploadSourceURL, error)
        case (.some(let error), .document):
            self.documentDelegate?.didFailDocumentDownload(smeHTTPRequest.noTokenURL, error)
        case (.none, .document):
            self.settingsManager.lastOnlineDate = Date()
            
            //smeHTTPRequest.finishEncryptionIfNeeded()
            self.documentDelegate?.didFinishDocumentDownload(smeHTTPRequest.noTokenURL, smeHTTPRequest.responseData)
        case (.none, .documentUpload):
            self.documentDelegate?.didFinishDocumentUpload(smeHTTPRequest.requestData.uploadSourceURL)
        default:
            break
        }
    }
    
    
    // MARK: - URLSessionDataDelegate -
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        completionHandler(.allow)
        
        guard
            let url = (dataTask.currentRequest?.url).asOptional(dataTask.taskDescription?.url),
            let smeHTTPRequest = self.activeDownloadRequests[url] else { return }
        
        switch (smeHTTPRequest.requestData.preloadRequest,
                smeHTTPRequest.requestData.type) {
        case (true, .document),
            (true, .documentUpload):
            self.documentDelegate?.didStartDocumentPreload(self.cacheVerifyManager.getTitleOfDocument(smeHTTPRequest.requestData.coverURL),
                                                           response.expectedContentLength)
        case (_, .document):
            self.documentDelegate?.didStartDocumentDownload(smeHTTPRequest.noTokenURL, response.expectedContentLength)
        case (_, .documentUpload):
            self.documentDelegate?.didStartDocumentUpload(smeHTTPRequest.noTokenURL)
        default:
            break
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard
            let url = (dataTask.currentRequest?.url).asOptional(dataTask.taskDescription?.url),
            let smeHTTPRequest = self.activeDownloadRequests[url] else { return }
        
        smeHTTPRequest.responseStatusCode = dataTask.response?.httpStatusCode
        smeHTTPRequest.responseStatusMessage = dataTask.response?.statusCodeDescription
        
        if smeHTTPRequest.responseStatusCode != 200 {
            smeHTTPRequest.error = .didReceiveDataFail(smeHTTPRequest.responseStatusCode)
        }
        
        let cancelDataTask: (UInt, _Error) -> Void = { count, error in
            dataTask.cancel()
            
            self.signalSemaphore(count)
            
            self.documentDelegate?.didFailDocumentDownload(smeHTTPRequest.noTokenURL, error)
        }
        
        let cancelDataTaskAndMore: (_Error) -> Void = { error in
            cancelDataTask(1, error)
            
            guard
                smeHTTPRequest.requestData.preloadRequest,
                smeHTTPRequest.requestData.type == .document else { return }
            
            self.signalSemaphore(4)
        }
        
        let cancelDataTaskAndMoreAndSetError: (_Error) -> Void = { error in
            self.errorManager.setError(error)
            // FIXME: - We should write this logic -
            /*
             [[SMEDataManager sharedInstance].serverErrorHandler logErrorWithCode:aRequest.error.code paramsArray:nil];
             [[SMEDataManager sharedInstance] processFailedRequest:aRequest];
             [[SMEDataManager sharedInstance] processFinishedDocumentRequest:aRequest];
             */
            cancelDataTaskAndMore(error)
        }
        
        switch (smeHTTPRequest.requestData.preloadRequest,
                smeHTTPRequest.requestData.type,
                smeHTTPRequest.responseStatusCode,
                self.macrosInfoProvider.is(._OKTA_AUTH)) {
        case (true, .document, _, _) where self.currentDocumentTimestamp != self.currentPreloadTimestamp:
            cancelDataTask(5, .requestCanceledReasonIsInvalidTimestamp)
            /*case (false, .document, _, _) where self.currentDocumentTimestamp != self.timestamps[.document]:
             cancelDataTask(1)*/
        case (_, .document, .some(411), true),
            (_, .documentUpload, .some(411), true),
            (_, .document, .some(417), true),
            (_, .documentUpload, .some(417), true):
            // FIXME: - [appDelegate startAgain]; -
            async {
                GFACoordinator.shared.start(cleanCredentials: true)
            }
            
            cancelDataTaskAndMore(.didReceiveDataFailTokenExpired)
        case (_, .document, .some(411), false),
            (_, .documentUpload, .some(411), false),
            (_, .document, .some(417), false),
            (_, .documentUpload, .some(417), false):
            // FIXME: - loginWithLogin; -
            async {
                GFACoordinator.shared.start(cleanCredentials: true)
            }
            
            cancelDataTaskAndMore(.didReceiveDataFailTokenExpired)
        case (false, .document, .some(403), _),
            (false, .documentUpload, .some(403), _):
            cancelDataTaskAndMoreAndSetError(.didReceiveDataFail(2033))
        case (false, .document, .some(400..<600), _),
            (false, .documentUpload, .some(400..<600), _):
            cancelDataTaskAndMoreAndSetError(.didReceiveDataFail(2034))
        case (true, .document, .some(403), _),
            (true, .documentUpload, .some(403), _):
            cancelDataTaskAndMoreAndSetError(.didReceiveDataFail(2036))
        case (true, .document, .some(400..<600), _),
            (true, .documentUpload, .some(400..<600), _):
            cancelDataTaskAndMoreAndSetError(.didReceiveDataFail(2037))
        case (_, _, .some(400..<600), _):
            cancelDataTaskAndMore(.didReceiveDataFailTokenExpired)
        case (true, .document, _, _):
            self.documentDelegate?.didReceiveDocumentPreload(data.count)
            
            smeHTTPRequest.addData(data)
        case (false, .document, _, _):
            self.documentDelegate?.didReceiveDocumentDownload(smeHTTPRequest.noTokenURL, data.count)
            
            smeHTTPRequest.addData(data)
        default:
            smeHTTPRequest.addData(data)
        }
    }
}
