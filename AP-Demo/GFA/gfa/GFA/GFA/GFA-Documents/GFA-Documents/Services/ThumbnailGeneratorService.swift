//
//  ThumbnailGeneratorService.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/8/23.
//

import QuickLook

final
class ThumbnailGeneratorService {
    private let thumbnailGenerator = QLThumbnailGenerator.shared
    
    
    func generate(_ url: URL, _ completion: @escaping (UIImage) -> Void) {
        self.thumbnailGenerator.generateBestRepresentation(for: .init(fileAt: url,
                                                                      size: CGSize(width: 300, height: 400),
                                                                      scale: UIScreen.main.scale,
                                                                      representationTypes: .thumbnail)) { (thumbnail, error) in
            guard let thumbnailImage = thumbnail?.uiImage else { return }
            
            completion(thumbnailImage)
        }
    }
}
