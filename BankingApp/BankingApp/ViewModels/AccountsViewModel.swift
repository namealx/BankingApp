//
//  AccountsViewModel.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import Combine

final class AccountsViewModel: ObservableObject {
    
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var filterType: TransactionType? = nil
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    @Published var isLoading: Bool = false
    
    @Published var newAccountName: String = ""
    @Published var newAccountType: AccountType = .current
    @Published var newCardSubtype: CardSubtype = .savings
    @Published var newAccountCurrency: String = "BYN"
    
    private let db = DatabaseManager.shared
    
    var totalBalanceInBYN: Double {
        let rateMap = buildRateMap()
        return accounts.reduce(0.0) { sum, account in
            sum + account.balance * (rateMap[account.currency] ?? 1.0)
        }
    }
    
    func loadAccounts(userId: Int64) {
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            do {
                let loaded = try self?.db.getAccounts(userId: userId) ?? []
                DispatchQueue.main.async {
                    self?.accounts = loaded
                    self?.isLoading = false
                    self?.objectWillChange.send()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    func updateAccountBalanceLocally(id: Int64, newBalance: Double) {
        if let index = accounts.firstIndex(where: { $0.id == id }) {
            var updatedAccount = accounts[index]
            updatedAccount.balance = newBalance
            accounts[index] = updatedAccount
            objectWillChange.send()
        }
    }
    
    func createAccount(userId: Int64) {
        guard !newAccountName.isEmpty else {
            errorMessage = "error_enter_account_name".localized
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let account = Account(
            userId: userId,
            name: newAccountName,
            type: newAccountType,
            cardSubtype: newAccountType == .card ? newCardSubtype : nil,
            currency: newAccountCurrency, balance: 0,
            overdraftLimit: 0.0
        )
        
        DispatchQueue.global().async { [weak self] in
            do {
                _ = try self?.db.createAccount(account)
                DispatchQueue.main.async {
                    if let userId = self?.accounts.first?.userId {
                        self?.loadAccounts(userId: userId)
                    }
                    self?.newAccountName = ""
                    self?.successMessage = "account_created".localized
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
    
    func deleteAccount(id: Int64, transferToId: Int64? = nil, completion: (() -> Void)? = nil) {
        isLoading = true
        successMessage = ""
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            guard let accountToDelete = self.accounts.first(where: { $0.id == id }) else {
                DispatchQueue.main.async {
                    self.errorMessage = "error_account_not_found".localized
                    self.isLoading = false
                }
                return
            }
            
            if accountToDelete.hasOverdraft && accountToDelete.balance < 0 {
                DispatchQueue.main.async {
                    self.errorMessage = "cannot_delete_overdraft".localized
                    self.isLoading = false
                }
                return
            }
            
            // Перенос баланса при необходимости
            if accountToDelete.balance > 0, let transferId = transferToId,
               let target = self.accounts.first(where: { $0.id == transferId }) {
                
                let rateMap = self.buildRateMap()
                let amountInBYN = accountToDelete.balance * (rateMap[accountToDelete.currency] ?? 1.0)
                let amountToTransfer = amountInBYN / (rateMap[target.currency] ?? 1.0)
                
                do {
                    try self.db.updateAccountBalance(id: transferId, balance: target.balance + amountToTransfer)
                    
                    DispatchQueue.main.async {
                        self.updateAccountBalanceLocally(id: transferId, newBalance: target.balance + amountToTransfer)
                    }
                } catch { }
            }
            
            do {
                try self.db.setAccountInactive(id: id)
                DispatchQueue.main.async {
                    self.accounts.removeAll { $0.id == id }
                    self.successMessage = "account_closed".localized
                    self.isLoading = false
                    self.objectWillChange.send()
                    completion?()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    completion?()
                }
            }
        }
    }
    
    func loadTransactions(for account: Account) {
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            do {
                let txs = try self?.db.getTransactions(accountId: account.id) ?? []
                DispatchQueue.main.async {
                    self?.transactions = txs
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
    
    private func buildRateMap() -> [String: Double] {
        return [
            "BYN": 1.0, "USD": 3.245, "EUR": 3.512,
            "RUB": 0.0362, "GBP": 4.123, "CNY": 0.449, "PLN": 0.811
        ]
    }
}
