//
//  SMEFileManager.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/7/23.
//

import Foundation

final
class SMEFileManager {
    private let fileManager = FileManager.default
    private lazy var documentDirectory: URL = self.fileManager.urls(for: .documentDirectory,
                                                                    in: .userDomainMask).first!
    
    enum _Error: Error, IErrorCode {
        case writingDataFail(_ error: Error)
        
        var code: Int {
            2145
        }
    }
    
    
    func write(_ data: Data, _ filePath: String, _ completion:(Result<URL, _Error>) -> Void) {
        let fileURL = self.documentDirectory.appendingPathComponent(filePath)
        
        do {
            try data.write(to: fileURL)
            
            completion(.success(fileURL))
        } catch {
            completion(.failure(.writingDataFail(error)))
        }
    }
}
