//
//  SMERequestErrorType.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/6/23.
//

enum SMERequestErrorType: Int {
    case SMERET_NO_ERROR = 0
    case SMERET_SERVER_ERROR = 1
    case SMERET_REQUEST_FAILED = 2
    case SMERET_AUTH_FAILED = 3
    case SMERET_REQUEST_CANCELED = 4
    case SMERET_NO_CONNECTION = 5
    case SMERET_NO_PERMISSIONS = 6
    case SMERET_UPLOAD_SOURCE_ERROR = 7
}
