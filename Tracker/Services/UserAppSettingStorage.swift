//
//  UserAppSettingStorage.swift
//  Tracker
//
//  Created by Ilya Nikitash on 2/28/25.
//
import Foundation

protocol UserAppSettingsStorageProtocol {
    func clean()
}

final class UserAppSettingStorage: UserAppSettingsStorageProtocol {
    static let shared = UserAppSettingStorage()
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case selectedFilter
    }
    
    var selectedFilter: FilterCases? {
        get {
            guard let selectedFilter = userDefaults.string(forKey: Keys.selectedFilter.rawValue) else {
                return nil
            }
            
            return FilterCases(rawValue: selectedFilter)
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: Keys.selectedFilter.rawValue)
        }
    }
    
    private init() {}
    
    func clean() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}
