//
//  SMEErrorManager.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/10/23.
//

import Foundation

final
class SMEErrorManager {
    private let errorCodes: [String: Any]
    private let defaultErrorCodes: [String: Any]
    private(set) var currentError: IErrorCode? = .none
    
    static let shared: SMEErrorManager = SMEErrorManager()!
    
    
    private init?() {
        guard
            let errorCodesURL = Bundle.gfa.url(forResource: "appcodes", withExtension: "json"),
            let errorCodesData = try? Data(contentsOf: errorCodesURL),
            let errorCodesDictionary = try? JSONSerialization.jsonObject(with: errorCodesData) as? [String: Any] else { return nil }
        
        self.defaultErrorCodes = errorCodesDictionary
        self.errorCodes = .default
        // FIXME: - We need to add this logic in the future -
        //self.errorCodes = (NSDictionary *)[SMEUtils getDeserializedObjectForKey:@"errorCodesData"];
    }
    
    
    // MARK: - Methods -
    
    func message(_ error: IErrorCode) -> String {
        (self.errorCodes.valueForKeyPath("data.error.en.\(error.code).user_message")).as(
            (self.defaultErrorCodes.valueForKeyPath("data.error.en.\(error.code).user_message")).as(
                "Error \(error.code)"
            )
        )
    }
    
    func reset() {
        self.currentError = .none
    }
    
    func setError(_ error: IErrorCode) {
        self.currentError = error
        // FIXME: - We need implemente Logger in the future -
        //[[SMEDataManager sharedInstance].serverErrorHandler logErrorWithCode:self.currentError?.code paramsArray:nil];
    }
}
