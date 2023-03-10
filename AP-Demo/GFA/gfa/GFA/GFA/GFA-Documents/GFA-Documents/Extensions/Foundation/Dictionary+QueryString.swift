//
//  Dictionary+QueryString.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/3/23.
//

extension Dictionary {
    var queryString: String {
        let query = self.reduce(.default) { (result, keyValue) -> String in
            var string: String = .default
            
            if let values = keyValue.value as? Array<Any> {
                string = values.map({"\(keyValue.key)[]=\($0)&"}).reduce("", +)
            } else {
                string = "\(keyValue.key)=\(keyValue.value)&"
            }
            
            return (result + string)
        }.dropLast()
        
        return "?" + String(query)
    }
}
