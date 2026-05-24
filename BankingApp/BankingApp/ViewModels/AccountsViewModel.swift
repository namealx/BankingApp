//
//  AccountsViewModel.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import Combine

// MARK: - AccountsViewModel
final class AccountsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var filterType: TransactionType? = nil
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    @Published var isLoading: Bool = false
    
    // MARK: - New Account Form
    @Published var newAccountName: String = ""
    @Published var newAccountType: AccountType = .current
    @Published var newCardSubtype: CardSubtype = .salary
    @Published var newAccountCurrency: String = "BYN"
    
    // MARK: - Dependencies
    private let db = DatabaseManager.shared
    
    // MARK: - Computed Properties
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var totalBalanceInBYN: Double {
        let rateMap = buildRateMap()
        return accounts.reduce(0.0) { sum, account in
            sum + account.balance * (rateMap[account.currency] ?? 1.0)
        }
    }
    
    // MARK: - Load Accounts
    func loadAccounts(userId: Int64) {
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            do {
                let accounts = try self?.db.getAccounts(userId: userId) ?? []
                DispatchQueue.main.async {
                    self?.accounts = accounts
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Create Account
    func createAccount(userId: Int64) {
        guard !newAccountName.isEmpty else {
            errorMessage = "Введите название счета"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let isSalary = newAccountType == .card && newCardSubtype == .salary
        let account = Account(
            userId: userId,
            name: newAccountName,
            type: newAccountType,
            cardSubtype: newAccountType == .card ? newCardSubtype : nil,
            balance: 0,
            currency: newAccountCurrency,
            hasOverdraft: isSalary,
            overdraftLimit: isSalary ? 500.0 : 0.0
        )
        
        DispatchQueue.global().async { [weak self] in
            do {
                _ = try self?.db.createAccount(account)
                DispatchQueue.main.async {
                    self?.loadAccounts(userId: userId)
                    self?.newAccountName = ""
                    self?.successMessage = "Счет успешно создан"
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount(id: Int64, transferToId: Int64? = nil) {
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            guard let accountToDelete = self?.accounts.first(where: { $0.id == id }) else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Счет не найден"
                    self?.isLoading = false
                }
                return
            }
            
            // Проверка на отрицательный баланс при овердрафте
            if accountToDelete.hasOverdraft && accountToDelete.balance < 0 {
                DispatchQueue.main.async {
                    self?.errorMessage = "Невозможно удалить счет с отрицательным балансом"
                    self?.isLoading = false
                }
                return
            }
            
            // Перенос положительного баланса
            if accountToDelete.balance > 0,
               let transferId = transferToId,
               let targetAccount = self?.accounts.first(where: { $0.id == transferId }) {
                
                let rateMap = self?.buildRateMap() ?? [:]
                let amountInBYN = accountToDelete.balance * (rateMap[accountToDelete.currency] ?? 1.0)
                let amountToTransfer = amountInBYN / (rateMap[targetAccount.currency] ?? 1.0)
                
                do {
                    try self?.db.updateAccountBalance(id: transferId, balance: targetAccount.balance + amountToTransfer)
                    
                    let transferTx = Transaction(
                        accountId: transferId,
                        type: .income,
                        amount: amountToTransfer,
                        currency: targetAccount.currency,
                        description: "Перевод со счета \(accountToDelete.name) при удалении"
                    )
                    _ = try self?.db.addTransaction(transferTx)
                } catch {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Ошибка переноса средств: \(error.localizedDescription)"
                        self?.isLoading = false
                    }
                    return
                }
            }
            
            do {
                try self?.db.setAccountInactive(id: id)
                DispatchQueue.main.async {
                    if let userId = self?.accounts.first(where: { $0.id == id })?.userId {
                        self?.loadAccounts(userId: userId)
                    }
                    self?.successMessage = "Счет успешно удален"
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Load Transactions
    func loadTransactions(for account: Account) {
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            do {
                let transactions = try self?.db.getTransactions(accountId: account.id) ?? []
                DispatchQueue.main.async {
                    self?.transactions = transactions
                    self?.applyFilter()
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Filter Transactions
    func applyFilter() {
        if let type = filterType {
            filteredTransactions = transactions.filter { $0.type == type }
        } else {
            filteredTransactions = transactions
        }
    }
    
    func setFilter(_ type: TransactionType?) {
        filterType = type
        applyFilter()
    }
    
    // MARK: - Helpers
    private func buildRateMap() -> [String: Double] {
        return [
            "BYN": 1.0,
            "USD": 3.245,
            "EUR": 3.512,
            "RUB": 0.0362,
            "GBP": 4.123,
            "CNY": 0.449,
            "PLN": 0.811
        ]
    }
}
