//
//  MessagingService.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/20/23.
//

final
class MessagingService {
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    var didReceiveMessage: MessagingService.DidReceiveMessageHandler = .none
    
    typealias DidReceiveMessageHandler = ((Message) -> Void)?
    
    
    func send(_ messages: Message...) {
        messages.forEach({
            notificationCenter.post($0.notification)
        })
    }
    
    func subscribe(_ messages: Message...) {
        messages.forEach({
            self.notificationCenter.addObserver(self,
                                                selector: #selector(self.receiveMessageHandler(_:)),
                                                name: $0.notificationName,
                                                object: .none)
        })
    }
    
    func unSubscribe(_ messages: Message...) {
        messages.forEach({
            self.notificationCenter.removeObserver(self,
                                                   name: $0.notificationName,
                                                   object: .none)
        })
    }
    
    func subscribe(_ messageSubscribers: MessageSubscriber...) {
        messageSubscribers.forEach({
            self.notificationCenter.addObserver($0.subscriber,
                                                selector: $0.selector,
                                                name: $0.message.notificationName,
                                                object: .none)
        })
    }
    
    func unSubscribe(_ messageSubscribers: MessageSubscriber...) {
        messageSubscribers.forEach({
            self.notificationCenter.removeObserver($0.subscriber,
                                                   name: $0.message.notificationName,
                                                   object: .none)
        })
    }
    
    
    // MARK: - Private Implementation -
    
    @objc
    private func receiveMessageHandler(_ notification: Notification) {
        guard let message = Message(notification) else { return }
        
        async { [weak self] in
            self?.didReceiveMessage?(message)
        }
    }
}


// MARK: - Message+Notification -

import UIKit

fileprivate extension Message {
    var notification: Notification {
        Notification(name: self.notificationName,
                     object: self.messageInfo?.sender,
                     userInfo: self.messageInfo?.info)
    }
    
    var notificationName: Notification.Name {
        enum Keys: String { case coreDataInitialized, UserDataUpdated, NotificationTextResourcesUpdated,
                                 usmLogoutWasFinished, MainSectionCountryChanged }
        
        switch self {
        case .coreDataInitialized: return Notification.Name(rawValue: Keys.coreDataInitialized.rawValue)
        case .textResourcesUpdated: return Notification.Name(rawValue: Keys.NotificationTextResourcesUpdated.rawValue)
        case .keyboardWillChangeFrame: return UIResponder.keyboardWillChangeFrameNotification
        case .appDidBecomeActive: return UIApplication.didBecomeActiveNotification
        case .appWillResignActive: return UIApplication.willResignActiveNotification
        case .appWillEnterForeground: return UIApplication.willEnterForegroundNotification
        case .userDataUpdated: return Notification.Name(rawValue: Keys.UserDataUpdated.rawValue)
        case .usmLogoutWasFinished: return Notification.Name(rawValue: Keys.usmLogoutWasFinished.rawValue)
        case .mainSectionCountryChanged: return Notification.Name(rawValue: Keys.MainSectionCountryChanged.rawValue)
        }
    }
    
    
    init?(_ notification: Notification) {
        let messageInfo = MessageInfo(notification.object, info: notification.userInfo)
        
        let all: [Message] = [
            .coreDataInitialized(messageInfo),
            .textResourcesUpdated(messageInfo),
            .keyboardWillChangeFrame(messageInfo),
            .appDidBecomeActive(messageInfo),
            .appWillResignActive(messageInfo),
            .appWillEnterForeground(messageInfo),
            .userDataUpdated(messageInfo),
            .usmLogoutWasFinished(messageInfo),
            .mainSectionCountryChanged(messageInfo),
        ]
        
        guard let message = all.first(where: {
            $0.notificationName == notification.name
        }) else { return nil }
        
        self = message
    }
}
