//
//  BankingAppApp.swift
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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(settings)
                .preferredColorScheme(settings.swiftUIColorScheme)
        }
    }
}
