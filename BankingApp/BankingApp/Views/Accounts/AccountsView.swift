//
//  AccountsView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI

struct AccountsView: View {
    
    @EnvironmentObject var accountsVM: AccountsViewModel
    @EnvironmentObject var transferVM: TransferViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showCreateSheet = false
    @State private var showAllAccounts = true
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    
    var displayedAccounts: [Account] {
        showAllAccounts ? accountsVM.accounts : accountsVM.accounts.filter { $0.isActive }
    }
    
    private func formatAmount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else if value * 10 - floor(value * 10) < 0.001 {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
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
                
                Section {
                    Picker("Показать", selection: $showAllAccounts) {
                        Text("Все счета").tag(true)
                        Text("Активные").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Мои счета") {
                    if accountsVM.isLoading {
                        ProgressView()
                    } else if displayedAccounts.isEmpty {
                        Text("Нет счетов").foregroundColor(.gray)
                    } else {
                        ForEach(displayedAccounts) { account in
                            NavigationLink(destination: AccountDetailView(account: account)
                                .environmentObject(accountsVM)
                                .environmentObject(transferVM)
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
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: refreshAccounts) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable { refreshAccounts() }
            .sheet(isPresented: $showCreateSheet) {
                CreateAccountSheet()
                    .environmentObject(accountsVM)
                    .environmentObject(authVM)
            }
            .alert("Успех", isPresented: $showSuccessAlert) {
                Button("OK") {
                    accountsVM.successMessage = ""
                }
            } message: {
                Text(accountsVM.successMessage)
            }
            .alert("Ошибка", isPresented: $showErrorAlert) {
                Button("OK") { accountsVM.errorMessage = "" }
            } message: {
                Text(accountsVM.errorMessage)
            }
            .onReceive(accountsVM.$successMessage) { msg in
                if !msg.isEmpty {
                    showSuccessAlert = true
                }
            }
            .onReceive(accountsVM.$errorMessage) { msg in
                if !msg.isEmpty {
                    showErrorAlert = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshAccounts"))) { _ in
                if let userId = authVM.currentUser?.id {
                    accountsVM.loadAccounts(userId: userId)
                }
            }
        }
    }
    
    private func refreshAccounts() {
        if let userId = authVM.currentUser?.id {
            accountsVM.loadAccounts(userId: userId)
        }
    }
}

// MARK: - AccountRowView
struct AccountRowView: View {
    let account: Account
    
    private func formatAmount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else if value * 10 - floor(value * 10) < 0.001 {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(account.name).font(.headline)
                Text(account.type.localizedName).font(.caption).foregroundColor(.secondary)
                if account.hasOverdraft {
                    Text("Овердрафт: \(Int(account.overdraftLimit)) BYN")
                        .font(.caption2).foregroundColor(.orange)
                }
                if !account.isActive {
                    Text("Закрыт").font(.caption2).foregroundColor(.red)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formatAmount(account.balance)).font(.headline)
                Text(account.currency).font(.caption).foregroundColor(.secondary)
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
        case .credit:  return "creditcard.trianglebadge.exclamationmark"
        case .card:    return "creditcard"
        }
    }
    
    private var iconColor: Color {
        switch account.type {
        case .current: return .blue
        case .savings: return .green
        case .credit:  return .red
        case .card:    return .purple
        }
    }
}

// MARK: - AccountDetailView
struct AccountDetailView: View {
    let account: Account
    
    @EnvironmentObject var accountsVM: AccountsViewModel
    @EnvironmentObject var transferVM: TransferViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedFilter: TransactionType? = nil
    @State private var showDeleteSheet = false
    @State private var currentBalance: Double
    
    init(account: Account) {
        self.account = account
        _currentBalance = State(initialValue: account.balance)
    }
    
    private func formatAmount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else if value * 10 - floor(value * 10) < 0.001 {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Баланс").font(.caption).foregroundColor(.secondary)
                    Text(formatAmount(currentBalance) + " " + account.currency)
                        .font(.title.bold())
                    if account.hasOverdraft {
                        Text("Доступно с овердрафтом: \(formatAmount(account.availableBalance)) \(account.currency)")
                            .font(.caption).foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 8)
            }
            
            if account.isActive {
                Section("Действия") {
                    Button {
                        
                        transferVM.fromAccount = account
                        transferVM.toAccount = nil
                        transferVM.amountString = ""
                        transferVM.errorMessage = ""
                        transferVM.successMessage = ""
                        transferVM.isTransferComplete = false
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchToTransferTab"), object: nil)
                    } label: {
                        Label("Перевести средства", systemImage: "arrow.right.circle")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteSheet = true
                    } label: {
                        Label("Закрыть счет", systemImage: "trash")
                    }
                }
            }
            
            Section("Информация") {
                HStack { Text("Номер счета"); Spacer(); Text("\(account.id)").foregroundColor(.secondary) }
                HStack { Text("Тип счета"); Spacer(); Text(account.type.localizedName).foregroundColor(.secondary) }
                HStack { Text("Статус"); Spacer(); Text(account.isActive ? "Активен" : "Закрыт").foregroundColor(account.isActive ? .green : .red) }
                HStack { Text("Дата открытия"); Spacer(); Text(account.createdAt.formatted(date: .abbreviated, time: .omitted)).foregroundColor(.secondary) }
            }
            
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
            
            Section("История операций") {
                if accountsVM.filteredTransactions.isEmpty {
                    Text("Нет операций").foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .center).padding()
                } else {
                    ForEach(accountsVM.filteredTransactions) { tx in
                        TransactionRowView(transaction: tx)
                    }
                }
            }
        }
        .navigationTitle(account.name)
        .onAppear {
            accountsVM.loadTransactions(for: account)
            if let updated = accountsVM.accounts.first(where: { $0.id == account.id }) {
                currentBalance = updated.balance
            }
        }
       
        .onReceive(accountsVM.$accounts) { updatedAccounts in
            if let updated = updatedAccounts.first(where: { $0.id == account.id }) {
                currentBalance = updated.balance
            }
        }
        .sheet(isPresented: $showDeleteSheet) {
            DeleteAccountSheet(account: account) {
                dismiss()
            }
            .environmentObject(accountsVM)
            .environmentObject(authVM)
        }
    }
}

// MARK: - TransactionRowView
struct TransactionRowView: View {
    let transaction: Transaction
    
    private func formatAmount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 { return String(format: "%.0f", value) }
        else if value * 10 - floor(value * 10) < 0.001 { return String(format: "%.1f", value) }
        else { return String(format: "%.2f", value) }
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description).font(.subheadline)
                Text(transaction.createdAt, style: .date).font(.caption).foregroundColor(.secondary)
            }
            
            Spacer()
            Text(String(format: "%@%@ %@", prefix, formatAmount(transaction.amount), transaction.currency))
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
                        ForEach(["BYN", "USD", "EUR", "RUB"], id: \.self) { c in Text(c).tag(c) }
                    }
                }
                if !accountsVM.errorMessage.isEmpty {
                    Section { Text(accountsVM.errorMessage).foregroundColor(.red) }
                }
                Section {
                    Button("Создать счет") {
                        if let userId = authVM.currentUser?.id {
                            accountsVM.createAccount(userId: userId)
                            if accountsVM.errorMessage.isEmpty { dismiss() }
                        }
                    }
                    .disabled(accountsVM.isLoading)
                    .accessibilityIdentifier("createAccountConfirmButton")
                }
            }
            .navigationTitle("Новый счет")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } } }
        }
    }
}

// MARK: - DeleteAccountSheet
struct DeleteAccountSheet: View {
    let account: Account
    let onDeleted: () -> Void
    @EnvironmentObject var accountsVM: AccountsViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTransferAccount: Account? = nil
    @State private var showConfirmAlert = false
    @State private var isDeleting = false
    
    private var otherAccounts: [Account] { accountsVM.accounts.filter { $0.id != account.id && $0.isActive } }
    private var hasBalance: Bool { account.balance > 0 }
    private var cannotDeleteDueToOverdraft: Bool { account.hasOverdraft && account.balance < 0 }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color.red.opacity(0.12)).frame(width: 80, height: 80)
                            Image(systemName: cannotDeleteDueToOverdraft ? "exclamationmark.triangle.fill" : "trash.circle.fill")
                                .font(.system(size: 42)).foregroundColor(.red)
                        }
                        Text("Закрыть счет").font(.title2.bold())
                        Text(account.name).font(.subheadline).foregroundColor(.secondary)
                    }
                    
                    if cannotDeleteDueToOverdraft {
                        VStack {
                            Text("Невозможно удалить счет с отрицательным балансом").font(.headline).multilineTextAlignment(.center).foregroundColor(.red)
                            Text(String(format: "Баланс: %.2f %@", account.balance, account.currency))
                        }.padding().background(Color.red.opacity(0.08)).cornerRadius(16)
                    } else if !hasBalance {
                        VStack {
                            Image(systemName: "checkmark.circle.fill").font(.largeTitle).foregroundColor(.green)
                            Text("Баланс счета: 0.00").font(.headline)
                        }.padding().background(Color.green.opacity(0.08)).cornerRadius(16)
                    } else {
                        VStack {
                            Text(String(format: "Баланс счета: %.2f %@", account.balance, account.currency)).font(.title3.bold())
                            Text("Средства будут перенесены на другой счет").foregroundColor(.orange)
                        }.padding().background(Color.orange.opacity(0.08)).cornerRadius(16)
                    }
                    
                    if !cannotDeleteDueToOverdraft && hasBalance && !otherAccounts.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Выберите счет для переноса средств").font(.footnote.bold())
                            ForEach(otherAccounts) { acc in
                                Button {
                                    selectedTransferAccount = acc
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(acc.name)
                                            Text(String(format: "%.2f %@", acc.balance, acc.currency)).font(.caption)
                                        }
                                        Spacer()
                                        Image(systemName: selectedTransferAccount?.id == acc.id ? "checkmark.circle.fill" : "circle")
                                    }
                                    .padding()
                                    .background(selectedTransferAccount?.id == acc.id ? Color.blue.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                }
                            }
                        }.padding(.horizontal)
                    }
                    
                    if isDeleting {
                        ProgressView()
                    }
                }
                .padding(.top)
            }
            
            Button {
                showConfirmAlert = true
            } label: {
                Text("Закрыть счет")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(cannotDeleteDueToOverdraft ? Color.gray : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .disabled(cannotDeleteDueToOverdraft || isDeleting)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
            .alert("Подтверждение", isPresented: $showConfirmAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Закрыть", role: .destructive) {
                    isDeleting = true
                    let transferId = selectedTransferAccount?.id
                    accountsVM.deleteAccount(id: account.id, transferToId: transferId) {
                        isDeleting = false
                        
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            onDeleted()
                        }
                    }
                }
            } message: {
                Text(cannotDeleteDueToOverdraft ? "Невозможно удалить счет с отрицательным балансом" : "Вы уверены?")
            }
            .onAppear {
                if hasBalance && !otherAccounts.isEmpty && selectedTransferAccount == nil {
                    selectedTransferAccount = otherAccounts.first
                }
            }
        }
    }
}
