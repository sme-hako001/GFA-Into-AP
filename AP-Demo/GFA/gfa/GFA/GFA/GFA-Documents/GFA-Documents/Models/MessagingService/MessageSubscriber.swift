//
//  MessageSubscriber.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/20/23.
//

import ObjectiveC

struct MessageSubscriber {
    let message: Message
    let subscriber: Any
    let selector: Selector!
    
    
    init(_ message: Message,
         _ subscriber: Any,
         _ selector: Selector! = .none) {
        self.message = message
        self.subscriber = subscriber
        self.selector = selector
    }
}
