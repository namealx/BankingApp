//
//  SettingsManager.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import SwiftUI
import Combine

// MARK: - SettingsManager
final class SettingsManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = SettingsManager()
    
    // MARK: - Keys
    private enum Keys {
        static let currentUserId = "currentUserId"
        static let colorScheme = "colorScheme"
        static let language = "language"
        static let notificationsEnabled = "notificationsEnabled"
        static let notificationTime = "notificationTime"
        static let favoriteCurrencies = "favoriteCurrencies"
    }
    
    // MARK: - Published Properties
    @Published var colorScheme: ColorSchemePreference
    @Published var language: AppLanguage
    @Published var notificationsEnabled: Bool
    @Published var notificationTime: Date
    @Published var favoriteCurrencies: [String]
    
    // MARK: - Current User Session
    var currentUserId: Int64? {
        get {
            let val = UserDefaults.standard.integer(forKey: Keys.currentUserId)
            return val == 0 ? nil : Int64(val)
        }
        set {
            if let id = newValue {
                UserDefaults.standard.set(Int(id), forKey: Keys.currentUserId)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.currentUserId)
            }
        }
    }
    
    // MARK: - Init
    private init() {
        let schemePref = UserDefaults.standard.string(forKey: Keys.colorScheme) ?? ColorSchemePreference.system.rawValue
        colorScheme = ColorSchemePreference(rawValue: schemePref) ?? .system
        
        let langPref = UserDefaults.standard.string(forKey: Keys.language) ?? AppLanguage.russian.rawValue
        language = AppLanguage(rawValue: langPref) ?? .russian
        
        notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
        notificationTime = (UserDefaults.standard.object(forKey: Keys.notificationTime) as? Date) ?? Date()
        favoriteCurrencies = UserDefaults.standard.stringArray(forKey: Keys.favoriteCurrencies) ?? ["USD", "EUR"]
    }
    
    // MARK: - Methods
    func logout() {
        currentUserId = nil
    }
    
    func saveUserSession(userId: Int64) {
        currentUserId = userId
    }
    
    func toggleFavoriteCurrency(_ code: String) {
        if favoriteCurrencies.contains(code) {
            favoriteCurrencies.removeAll { $0 == code }
        } else {
            favoriteCurrencies.append(code)
        }
        UserDefaults.standard.set(favoriteCurrencies, forKey: Keys.favoriteCurrencies)
    }
    
    func updateNotificationSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        UserDefaults.standard.set(notificationTime, forKey: Keys.notificationTime)
    }
    
    func updateAppearance() {
        UserDefaults.standard.set(colorScheme.rawValue, forKey: Keys.colorScheme)
        UserDefaults.standard.set(language.rawValue, forKey: Keys.language)
        applyLanguage()
    }
    
    private func applyLanguage() {
        UserDefaults.standard.set([language.locale], forKey: "AppleLanguages")
    }
    
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        UserDefaults.standard.set(0, forKey: "cacheSize")
    }
    
    // MARK: - Computed Properties
    var swiftUIColorScheme: ColorScheme? {
        switch colorScheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - Color Scheme Preference
enum ColorSchemePreference: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var localizedName: String {
        switch self {
        case .light: return "Светлая"
        case .dark: return "Темная"
        case .system: return "Системная"
        }
    }
}

// MARK: - App Language
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case russian = "ru"
    case belarusian = "be"
    
    var localizedName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .belarusian: return "Беларуская"
        }
    }
    
    var locale: String { rawValue }
}
