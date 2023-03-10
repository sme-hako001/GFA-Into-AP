//
//  MessageInfo.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/20/23.
//

struct MessageInfo {
    let sender: Any?
    let info: [AnyHashable : Any]?
    
    
    init(_ sender: Any?, info: [AnyHashable : Any]?) {
        self.sender = sender
        self.info = info
    }
}
