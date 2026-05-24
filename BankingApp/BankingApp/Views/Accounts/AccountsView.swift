//
//  AccountsView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI

// MARK: - AccountsView
struct AccountsView: View {
    
    @EnvironmentObject var accountsVM: AccountsViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showCreateSheet = false
    @State private var showAllAccounts = true
    
    var displayedAccounts: [Account] {
        showAllAccounts ? accountsVM.accounts : accountsVM.accounts.filter { $0.isActive }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: Total Balance Section
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Общий баланс")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f BYN", accountsVM.totalBalanceInBYN))
                            .font(.title.bold())
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: Filter Toggle
                Section {
                    Picker("Показать", selection: $showAllAccounts) {
                        Text("Все счета").tag(true)
                        Text("Активные").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: Accounts List
                Section("Мои счета") {
                    if accountsVM.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    } else if displayedAccounts.isEmpty {
                        Text("Нет счетов")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(displayedAccounts) { account in
                            NavigationLink(destination: AccountDetailView(account: account)
                                .environmentObject(accountsVM)
                                .environmentObject(authVM)) {
                                AccountRowView(account: account)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Счета")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addAccountButton")
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if let userId = authVM.currentUser?.id {
                            accountsVM.loadAccounts(userId: userId)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                if let userId = authVM.currentUser?.id {
                    accountsVM.loadAccounts(userId: userId)
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateAccountSheet()
                    .environmentObject(accountsVM)
                    .environmentObject(authVM)
            }
            .alert("Ошибка", isPresented: .constant(!accountsVM.errorMessage.isEmpty)) {
                Button("OK") { accountsVM.errorMessage = "" }
            } message: {
                Text(accountsVM.errorMessage)
            }
            .alert("Успех", isPresented: .constant(!accountsVM.successMessage.isEmpty)) {
                Button("OK") { accountsVM.successMessage = "" }
            } message: {
                Text(accountsVM.successMessage)
            }
        }
    }
}

// MARK: - AccountRowView
struct AccountRowView: View {
    
    let account: Account
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.headline)
                Text(account.type.localizedName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if account.hasOverdraft {
                    Text("Овердрафт: \(Int(account.overdraftLimit)) BYN")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                if !account.isActive {
                    Text("Закрыт")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(String(format: "%.2f", account.balance))
                    .font(.headline)
                Text(account.currency)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .opacity(account.isActive ? 1.0 : 0.6)
        .accessibilityIdentifier("accountRow_\(account.id)")
    }
    
    private var iconName: String {
        switch account.type {
        case .current: return "banknote"
        case .savings: return "chart.pie"
        case .credit: return "creditcard.trianglebadge.exclamationmark"
        case .card: return "creditcard"
        }
    }
    
    private var iconColor: Color {
        switch account.type {
        case .current: return .blue
        case .savings: return .green
        case .credit: return .red
        case .card: return .purple
        }
    }
}
