//
//  Optional+Nil.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/31/23.
//

extension Optional {
    var isNil: Bool {
        (self == nil)
    }
    
    var notNil: Bool {
        !self.isNil
    }
    
    func `as`(_ `default`: Wrapped) -> Wrapped {
        (self ?? `default`)
    }
    
    func `as`(_ initializer: () -> Wrapped) -> Wrapped {
        (self ?? initializer())
    }
    
    func asOptional(_ `default`: Wrapped?) -> Wrapped? {
        (self ?? `default`)
    }
}
