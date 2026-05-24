//
//  MainTabView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI

// MARK: - MainTabView
struct MainTabView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @StateObject private var accountsVM = AccountsViewModel()
    @StateObject private var transferVM = TransferViewModel()
    @StateObject private var currencyVM = CurrencyViewModel()
    @StateObject private var branchVM = BranchViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    
    @State private var accountsRefreshID = UUID()
    
    var body: some View {
        TabView {
            AccountsView()
                .environmentObject(accountsVM)
                .tabItem {
                    Label("Счета", systemImage: "creditcard")
                }
            
            TransferView()
                .environmentObject(accountsVM)
                .environmentObject(transferVM)
                .tabItem {
                    Label("Перевод", systemImage: "arrow.left.arrow.right")
                }
            
            CurrencyView()
                .environmentObject(currencyVM)
                .tabItem {
                    Label("Курсы", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            BranchMapView()
                .environmentObject(branchVM)
                .tabItem {
                    Label("Карта", systemImage: "map")
                }
            
            ProfileView()
                .environmentObject(profileVM)
                .tabItem {
                    Label("Профиль", systemImage: "person.circle")
                }
        }
        .onAppear {
            if let userId = authVM.currentUser?.id {
                accountsVM.loadAccounts(userId: userId)
                profileVM.loadUser(id: userId)
                currencyVM.loadRates()
                branchVM.loadBranches()
            }
        }
        .onReceive(transferVM.$isTransferComplete) { completed in
            if completed {
                if let userId = authVM.currentUser?.id {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        accountsVM.loadAccounts(userId: userId)
                        accountsRefreshID = UUID()
                    }
                }
            }
        }
    }
}
