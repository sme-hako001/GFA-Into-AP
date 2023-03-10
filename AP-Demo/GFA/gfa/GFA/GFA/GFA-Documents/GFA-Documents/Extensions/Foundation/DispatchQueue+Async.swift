//
//  DispatchQueue+Async.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/6/23.
//

import Foundation

func async(_ delay: Double,
           _ queue:  DispatchQueue = .main,
           _ execute: @escaping () -> Void) {
    let deadline = (DispatchTime.now() + delay)
    
    queue.asyncAfter(deadline: deadline, execute: execute)
}

func async(_ queue:  DispatchQueue = .main,
           _ execute: @escaping () -> Void) {
    queue.async(execute: execute)
}
