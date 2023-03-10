//
//  IErrorCode.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/10/23.
//

protocol IErrorCode: Error {
    var code: Int { get }
}

extension IErrorCode {
    var message: String {
        SMEErrorManager.shared.message(self)
    }
}
