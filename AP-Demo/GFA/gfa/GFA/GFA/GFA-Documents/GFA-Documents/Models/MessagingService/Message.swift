//
//  Message.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/20/23.
//

enum Message {
    case coreDataInitialized(_ messageInfo: MessageInfo? = .none)
    case textResourcesUpdated(_ messageInfo: MessageInfo? = .none)
    case keyboardWillChangeFrame(_ messageInfo: MessageInfo? = .none)
    case appDidBecomeActive(_ messageInfo: MessageInfo? = .none)
    case appWillResignActive(_ messageInfo: MessageInfo? = .none)
    case appWillEnterForeground(_ messageInfo: MessageInfo? = .none)
    case userDataUpdated(_ messageInfo: MessageInfo? = .none)
    case usmLogoutWasFinished(_ messageInfo: MessageInfo? = .none)
    case mainSectionCountryChanged(_ messageInfo: MessageInfo? = .none)
    
    var messageInfo: MessageInfo? {
        switch self {
        case let .coreDataInitialized(messageInfo): return messageInfo
        case let .textResourcesUpdated(messageInfo): return messageInfo
        case let .keyboardWillChangeFrame(messageInfo): return messageInfo
        case let .appDidBecomeActive(messageInfo): return messageInfo
        case let .appWillResignActive(messageInfo): return messageInfo
        case let .appWillEnterForeground(messageInfo): return messageInfo
        case let .userDataUpdated(messageInfo): return messageInfo
        case let .usmLogoutWasFinished(messageInfo): return messageInfo
        case let .mainSectionCountryChanged(messageInfo): return messageInfo
        }
    }
}
