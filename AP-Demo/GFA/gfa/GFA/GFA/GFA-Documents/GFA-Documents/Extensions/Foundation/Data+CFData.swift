//
//  Data+CFData.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/17/23.
//

import Foundation

extension Data {
    init(cfData: CFData) {
        self = Data(bytes: CFDataGetBytePtr(cfData),
                    count: CFDataGetLength(cfData))
    }
}
