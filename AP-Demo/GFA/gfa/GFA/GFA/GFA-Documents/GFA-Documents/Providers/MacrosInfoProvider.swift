//
//  MacrosInfoProvider.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/9/23.
//

class MacrosInfoProvider {
    private let allMarcos: [Macros]
    
    
    init() {
        var allMarcos: [Macros] = .default
        
#if _OKTA_AUTH
        allMarcos.append(._OKTA_AUTH)
#endif
#if _OKTA_AUTH
        allMarcos.append(._SME_TEST_VERSION)
#endif
        
        self.allMarcos = allMarcos
    }
    
    
    // MARK: - Methods -
    
    func `is`(_ macros: Macros) -> Bool {
        self.allMarcos.contains(macros)
    }
}
