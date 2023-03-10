//
//  SMEUtils.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/31/23.
//

import Foundation

struct USMSettings {
    static let usmBasicURL = "https://uat-auth-console.sonymusic.com/oauth2/openid/v1/authorize"
    static let usmRedirectURL = "https://samisstageapi.smedsp.com:8888/validate"
    static let usmClientID = "elNuVz9qeiF0cm1wSDJENDRGYio"
    static let usmInternalRedirectURL = "https://samisstage.smedsp.com/charts-ui2/#/auth/processor"
    //TODO: define usmLogoutUrl and usmPingUrl if necessary
}

final class SMEUtils {
    
    static func getCurrentLogin() -> String {
        .default
    }
//    + (NSString*)getCurrentLogin
//    {
//        NSString* retStr = nil;
//        NSMutableDictionary* query = [NSMutableDictionary dictionaryWithDictionary:@{(id)kSecClass:(id)kSecClassGenericPassword, (id)kSecAttrService:@"sme_login", (id)kSecAttrAccount:@"Login", (id)kSecReturnData:@YES}];
//        NSString *sharedKeychainGroupID = [SMEUtils keychainAccessGroupID];
//        if (sharedKeychainGroupID) {
//            [query setValue:sharedKeychainGroupID forKey:(id)kSecAttrAccessGroup];
//        }
//        CFDictionaryRef cfquery = (__bridge_retained CFDictionaryRef)query;
//        CFDataRef cfresult = NULL;
//        OSStatus status = SecItemCopyMatching(cfquery, (CFTypeRef *)&cfresult);
//        CFRelease(cfquery);
//        NSData *data = (__bridge_transfer NSData *)cfresult;
//        if (status == errSecSuccess)
//        {
//            retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        }
//        return retStr;
//    }
    
    class func dateToString(from date: Date, dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    class func stringToDate(from dateString: String, dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    class func valueOf(param: String, forURL: URL) -> String? {
        let urlComponents = URLComponents(url: forURL, resolvingAgainstBaseURL: false)
        guard let queryItem = urlComponents?.queryItems?.first(where: { $0.name == param }) else { return nil }
        return queryItem.value
    }
    
    class func stateStr(_ nonceStr: String) -> String {
        let stateParamsDict = ["r": USMSettings.usmInternalRedirectURL, "n": nonceStr, "c": USMSettings.usmClientID];
        guard let stateData = try? JSONSerialization.data(withJSONObject: stateParamsDict, options: []) else { return "" }
        return stateData.base64EncodedString()
    }
}
