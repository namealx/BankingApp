//
//  MainTabView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @StateObject private var accountsVM = AccountsViewModel()
    @StateObject private var transferVM = TransferViewModel()
    @StateObject private var currencyVM = CurrencyViewModel()
    @StateObject private var branchVM = BranchViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AccountsView()
                .environmentObject(accountsVM)
                .environmentObject(transferVM)
                .environmentObject(authVM)
                .tabItem {
                    Label("Счета", systemImage: "creditcard")
                }
                .tag(0)
            
            TransferView()
                .environmentObject(accountsVM)
                .environmentObject(transferVM)
                .environmentObject(authVM)
                .tabItem {
                    Label("Перевод", systemImage: "arrow.left.arrow.right")
                }
                .tag(1)
            
            CurrencyView()
                .environmentObject(currencyVM)
                .tabItem {
                    Label("Курсы", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            BranchMapView()
                .environmentObject(branchVM)
                .tabItem {
                    Label("Карта", systemImage: "map")
                }
                .tag(3)
            
            ProfileView()
                .environmentObject(profileVM)
                .tabItem {
                    Label("Профиль", systemImage: "person.circle")
                }
                .tag(4)
        }
        .onAppear {
            if let userId = authVM.currentUser?.id {
                accountsVM.loadAccounts(userId: userId)
                profileVM.loadUser(id: userId)
                currencyVM.loadRates()
                branchVM.loadBranches()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToTransferTab"))) { _ in
            selectedTab = 1
        }
        .onReceive(transferVM.$isTransferComplete) { completed in
            if completed, let userId = authVM.currentUser?.id {
                accountsVM.loadAccounts(userId: userId)
            }
        }
    }
}
