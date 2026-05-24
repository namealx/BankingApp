//
//  SettingsManager.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 22.05.2026
//  Group: 12b
//

import Foundation
import SwiftUI
import Combine

// MARK: - SettingsManager
final class SettingsManager: ObservableObject {
    // MARK: - Singleton
    static let shared = SettingsManager()
    private init() {}
    
    // MARK: - Published Properties
    @Published var colorScheme: ColorSchemePreference = .system
    @Published var language: AppLanguage = .russian
    
    // MARK: - Current User Session
    @Published var currentUserId: Int64?
    
    // MARK: - Computed Properties
    var swiftUIColorScheme: ColorScheme? {
        switch colorScheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    // MARK: - Methods
    func logout() {
        currentUserId = nil
    }
    
    func saveUserSession(userId: Int64) {
        currentUserId = userId
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
