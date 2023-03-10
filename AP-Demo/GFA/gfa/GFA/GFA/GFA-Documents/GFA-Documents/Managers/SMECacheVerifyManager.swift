//
//  SMECacheVerifyManager.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/6/23.
//

import Foundation

final class SMECacheVerifyManager {
    
    static let shared: SMECacheVerifyManager = SMECacheVerifyManager()

    enum _Error: Error {
        case dataPathNotFound
        case dataIsEmpty
        case decryptionFail
    }
    
    
    private init() {
        
    }
    
    
    func canUseCachedData(_ smeHttpRequest: SMEHTTPRequest) -> Bool {
        false
    }
    
    func useCacheResponse(_ smeHttpRequest: SMEHTTPRequest, _ completion: (Result<Data, _Error>) -> Void) {
        
    }
    
    func cache(_ smeHTTPRequest: SMEHTTPRequest, _ completion: (Result<Void, _Error>) -> Void) {
        completion(.success(()))
    }
    
    func getTitleOfDocument(_ documentURL: String) -> String? {
        .none
    }
    
    
//    - (NSString *)titleOfDocumentWithURL:(NSString *)documentURL {
//        if (self.hashDictionary == nil)
//        {
//            [self loadHashDictionary];
//        }
//        
//        NSDictionary* curHashDict = [self.hashDictionary objectForKey:@"c"];
//        NSString* typeNumber = [[NSNumber numberWithInteger:SMERT_DOCUMENT] stringValue];
//        NSDictionary *docAttributesDict = [[curHashDict objectForKey:typeNumber] objectForKey:documentURL];
//        NSString *docTitle = [docAttributesDict objectForKey:@"t"];
//        return docTitle;
//    }
    
//    - (void)useCacheResponseForRequest:(SMEHTTPRequest*)aRequest withCompletionHandler:(void (^)(NSData*, NSError*))handler
//    {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSString* dataPath = [[self class] filePathForURL:aRequest.noTokenURL generationIDString:aRequest.requestData.dcgenId sheetID:aRequest.requestData.sheetID];
//            if (dataPath)
//            {
//                if (aRequest.responseFilePath == nil)
//                {
//                    NSData* encryptedData = [[NSData alloc] initWithContentsOfFile:dataPath];
//                    NSData* aData = [NSData data];
//                    if ([encryptedData length])
//                    {
//                        aData = [RNDecryptor decryptData:encryptedData withPassword:self.password error:nil];
//                    }
//                    if (aData)
//                    {
//                        aRequest.responseData = aData;
//                    }
//                    else
//                    {
//                        aRequest.responseData = [NSMutableData data];
//                    }
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    handler(aRequest.responseData, nil);
//                });
//            }
//            else
//            {
//                // TODO: set cache error here?
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    handler(nil, [NSError errorWithDomain:@"SMEGeneralErrorDomain" code:404 userInfo:nil]);
//                });
//            }
//        });
//    }
}
