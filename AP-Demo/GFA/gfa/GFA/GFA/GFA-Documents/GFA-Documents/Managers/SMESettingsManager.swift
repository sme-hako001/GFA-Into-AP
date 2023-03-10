//
//  SMESettingsManager.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/13/23.
//

import Foundation

final
class SMESettingsManager {
    private let userDefaults: UserDefaults = UserDefaults.standard
    let basicURL: String
    let certifcateNameSSL: String
    let formatVersionOfDocumentsAvailable: String
    
    private enum Keys: String {
        case user
        case credentials
        case lastOnlineDate
    }
    
    var user: UserGFA! {
        set { self.set(newValue.data, .user) }
        get { self.get(.user) }
    }
    
    var credentials: Credentials? {
        set { self.set(newValue.data, .credentials) }
        get { self.get(.credentials) }
    }
    
    var lastOnlineDate: Date? {
        set { self.set(newValue, .lastOnlineDate) }
        get { self.userDefaults.value(forKey: Keys.lastOnlineDate.rawValue) as? Date }
    }
    
    
    init?() {
        guard
            let settingsUrl = Bundle.gfa.url(forResource: "SMESettings", withExtension: "plist"),
            let settingsData = try? Data(contentsOf: settingsUrl),
            let settingsDictionary = try? PropertyListSerialization.propertyList(from: settingsData, format: .none) as? [String: Any],
            let currentSettingsDictionary = settingsDictionary["GFA-Documents"] as? [String: Any],
            let basicURL = currentSettingsDictionary["basic_url"] as? String,
            let certifcateNameSSL = currentSettingsDictionary["ssl_cert_filename"] as? String,
            let formatVersionOfDocumentsAvailable = currentSettingsDictionary["format_version_of_documents_available"] as? String else { return nil }
        
        self.basicURL = basicURL
        self.certifcateNameSSL = certifcateNameSSL
        self.formatVersionOfDocumentsAvailable = formatVersionOfDocumentsAvailable
    }
    
    
    // MARK: - Methods -
    
    func clean() {
        self.user = .none
        self.credentials = .none
        self.lastOnlineDate = .none
    }
    
    
    // MARK: - Private Implementation -
    
    private func get<T: Decodable>(_ forKey: Keys) -> T! {
        self.userDefaults.data(forKey: forKey.rawValue)?.model()
    }
    
    private func set(_ value: Any?, _ forKey: Keys) {
        (value.isNil
         ? self.userDefaults.removeObject(forKey: forKey.rawValue)
         : self.userDefaults.set(value, forKey: forKey.rawValue))
        
        self.userDefaults.synchronize()
    }
}
