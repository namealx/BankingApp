//
//  ProfileView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI

// MARK: - ProfileView
struct ProfileView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        NavigationStack {
            Text("Profile Screen")
                .navigationTitle("Профиль")
        }
    }
}
