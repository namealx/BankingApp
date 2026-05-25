//
//  BankingApp.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 22.05.2026
//  Group: 12b
//

import SwiftUI

// MARK: - BankingApp Entry Point
@main
struct BankingApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var settings = SettingsManager.shared
    @State private var languageVersion = 0

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(languageVersion)
                .environmentObject(authVM)
                .environmentObject(settings)
                .preferredColorScheme(settings.swiftUIColorScheme)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                    languageVersion += 1
                }
                .onAppear {
                    // Для UI-тестов сбрасываем состояние
                    if ProcessInfo.processInfo.arguments.contains("--uitesting") {
                        settings.resetForTesting()
                    }
                }
        }
    }
}
