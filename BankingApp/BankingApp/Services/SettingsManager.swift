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

final class SettingsManager: ObservableObject {
    
    static let shared = SettingsManager()
    
    private enum Keys {
        static let colorScheme = "colorScheme"
        static let language = "language"
        static let notificationsEnabled = "notificationsEnabled"
        static let notificationTime = "notificationTime"
        static let favoriteCurrencies = "favoriteCurrencies"
        static let currentUserId = "currentUserId"
    }
    
    // MARK: - Published Properties с сохранением в UserDefaults
    @Published var colorScheme: ColorSchemePreference {
        didSet {
            UserDefaults.standard.set(colorScheme.rawValue, forKey: Keys.colorScheme)
        }
    }
    
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Keys.language)
            applyLanguage()
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    @Published var notificationTime: Date {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: Keys.notificationTime)
        }
    }
    
    @Published var favoriteCurrencies: [String] {
        didSet {
            UserDefaults.standard.set(favoriteCurrencies, forKey: Keys.favoriteCurrencies)
        }
    }
    
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
    
    // MARK: - Init (загрузка сохраненных настроек)
    private init() {
        // Загрузка темы
        let savedColorScheme = UserDefaults.standard.string(forKey: Keys.colorScheme) ?? ColorSchemePreference.system.rawValue
        colorScheme = ColorSchemePreference(rawValue: savedColorScheme) ?? .system
        
        // Загрузка языка
        let savedLanguage = UserDefaults.standard.string(forKey: Keys.language) ?? AppLanguage.russian.rawValue
        language = AppLanguage(rawValue: savedLanguage) ?? .russian
        
        // Загрузка уведомлений
        notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
        notificationTime = UserDefaults.standard.object(forKey: Keys.notificationTime) as? Date ?? Date()
        favoriteCurrencies = UserDefaults.standard.stringArray(forKey: Keys.favoriteCurrencies) ?? ["USD", "EUR"]
    }
    
    // MARK: - Methods
    func logout() {
        currentUserId = nil
    }
    
    func toggleFavoriteCurrency(_ code: String) {
        if favoriteCurrencies.contains(code) {
            favoriteCurrencies.removeAll { $0 == code }
        } else {
            favoriteCurrencies.append(code)
        }
    }
    
    private func applyLanguage() {
        UserDefaults.standard.set([language.locale], forKey: "AppleLanguages")
    }
    
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
    }
    
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
