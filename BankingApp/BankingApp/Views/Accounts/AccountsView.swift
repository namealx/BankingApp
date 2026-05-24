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

// MARK: - AccountDetailView
struct AccountDetailView: View {
    
    @State private var currentAccount: Account
    @EnvironmentObject var accountsVM: AccountsViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedFilter: TransactionType? = nil
    @State private var showDeleteSheet = false
    
    init(account: Account) {
        _currentAccount = State(initialValue: account)
    }
    
    var body: some View {
        List {
            // MARK: Balance Section
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Баланс")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f %@", currentAccount.balance, currentAccount.currency))
                        .font(.title.bold())
                    if currentAccount.hasOverdraft {
                        Text("Доступно с овердрафтом: \(String(format: "%.2f", currentAccount.availableBalance)) \(currentAccount.currency)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // MARK: Actions Section
            if currentAccount.isActive {
                Section("Действия") {
                    NavigationLink(destination: TransferView()
                        .environmentObject(accountsVM)
                        .environmentObject(authVM)) {
                        Label("Перевести средства", systemImage: "arrow.right.circle")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteSheet = true
                    } label: {
                        Label("Закрыть счет", systemImage: "trash")
                    }
                }
            }
            
            // MARK: Status Section
            Section("Информация") {
                HStack {
                    Text("Номер счета")
                    Spacer()
                    Text("\(currentAccount.id)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Тип счета")
                    Spacer()
                    Text(currentAccount.type.localizedName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Статус")
                    Spacer()
                    Text(currentAccount.isActive ? "Активен" : "Закрыт")
                        .foregroundColor(currentAccount.isActive ? .green : .red)
                }
                
                HStack {
                    Text("Дата открытия")
                    Spacer()
                    Text(currentAccount.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                }
            }
            
            // MARK: Filter Section
            Section {
                Picker("Фильтр", selection: $selectedFilter) {
                    Text("Все").tag(Optional<TransactionType>.none)
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.localizedName).tag(Optional(type))
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedFilter) { _, newValue in
                    accountsVM.setFilter(newValue)
                }
            }
            
            // MARK: Transactions Section
            Section("История операций") {
                if accountsVM.filteredTransactions.isEmpty {
                    Text("Нет операций")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(accountsVM.filteredTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
        }
        .navigationTitle(currentAccount.name)
        .onAppear {
            accountsVM.loadTransactions(for: currentAccount)
        }
        .onChange(of: accountsVM.accounts) { _, updatedAccounts in
            if let fresh = updatedAccounts.first(where: { $0.id == currentAccount.id }) {
                currentAccount = fresh
            }
        }
        .sheet(isPresented: $showDeleteSheet) {
            DeleteAccountSheet(account: currentAccount) {
                if let userId = authVM.currentUser?.id {
                    accountsVM.loadAccounts(userId: userId)
                }
                dismiss()
            }
            .environmentObject(accountsVM)
        }
    }
}

// MARK: - TransactionRowView
struct TransactionRowView: View {
    
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.subheadline)
                Text(transaction.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%@%.2f %@", prefix, transaction.amount, transaction.currency))
                .font(.headline)
                .foregroundColor(iconColor)
        }
        .padding(.vertical, 2)
    }
    
    private var iconName: String {
        switch transaction.type {
        case .income: return "arrow.down.circle"
        case .expense: return "arrow.up.circle"
        case .transfer: return "arrow.left.arrow.right.circle"
        }
    }
    
    private var iconColor: Color {
        switch transaction.type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
    
    private var prefix: String {
        switch transaction.type {
        case .income: return "+"
        case .expense: return "-"
        case .transfer: return ""
        }
    }
}

// MARK: - CreateAccountSheet
struct CreateAccountSheet: View {
    
    @EnvironmentObject var accountsVM: AccountsViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Информация о счете") {
                    TextField("Название счета", text: $accountsVM.newAccountName)
                        .accessibilityIdentifier("newAccountNameField")
                    
                    Picker("Тип счета", selection: $accountsVM.newAccountType) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Text(type.localizedName).tag(type)
                        }
                    }
                    
                    if accountsVM.newAccountType == .card {
                        Picker("Тип карты", selection: $accountsVM.newCardSubtype) {
                            ForEach(CardSubtype.allCases, id: \.self) { subtype in
                                Text(subtype.rawValue.capitalized).tag(subtype)
                            }
                        }
                    }
                    
                    Picker("Валюта", selection: $accountsVM.newAccountCurrency) {
                        ForEach(["BYN", "USD", "EUR", "RUB"], id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }
                
                if !accountsVM.errorMessage.isEmpty {
                    Section {
                        Text(accountsVM.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Создать счет") {
                        if let userId = authVM.currentUser?.id {
                            accountsVM.createAccount(userId: userId)
                            if accountsVM.errorMessage.isEmpty {
                                dismiss()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(accountsVM.isLoading)
                    .accessibilityIdentifier("createAccountConfirmButton")
                }
            }
            .navigationTitle("Новый счет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}
