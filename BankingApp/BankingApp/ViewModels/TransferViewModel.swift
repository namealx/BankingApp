//
//  TransferViewModel.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import Combine

// MARK: - TransferViewModel
final class TransferViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var fromAccount: Account?
    @Published var toAccount: Account?
    @Published var amountString: String = ""
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    @Published var isTransferComplete: Bool = false
    @Published var isProcessing: Bool = false
    
    // MARK: - Computed Properties
    var amount: Double { Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    
    // MARK: - Dependencies
    private let db = DatabaseManager.shared
    
    // MARK: - Currency Rates 
    private func rateToBYN(_ currency: String) -> Double {
        let rates: [String: Double] = [
            "BYN": 1.0,
            "USD": 3.245,
            "EUR": 3.512,
            "RUB": 0.0362,
            "GBP": 4.123,
            "CNY": 0.449,
            "PLN": 0.811
        ]
        return rates[currency] ?? 1.0
    }
    
    // MARK: - Perform Transfer
    func performTransfer(accounts: [Account]) {
        // Валидация
        guard validate(accounts: accounts) else { return }
        guard let from = fromAccount, let to = toAccount else { return }
        
        isProcessing = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            do {
                let rateFrom = self.rateToBYN(from.currency)
                let rateTo = self.rateToBYN(to.currency)
                let amountInBYN = self.amount * rateFrom
                let amountToReceive = amountInBYN / rateTo
                
                let newFromBalance = from.balance - self.amount
                let newToBalance = to.balance + amountToReceive
                
                // Обновление балансов
                try self.db.updateAccountBalance(id: from.id, balance: newFromBalance)
                try self.db.updateAccountBalance(id: to.id, balance: newToBalance)
                
                // Запись транзакции для отправителя
                let txFrom = Transaction(
                    accountId: from.id,
                    type: .transfer,
                    amount: self.amount,
                    currency: from.currency,
                    description: String(format: "Перевод на счет %@", to.name),
                    relatedAccountId: to.id
                )
                _ = try self.db.addTransaction(txFrom)
                
                // Запись транзакции для получателя
                let txTo = Transaction(
                    accountId: to.id,
                    type: .income,
                    amount: amountToReceive,
                    currency: to.currency,
                    description: String(format: "Перевод со счета %@", from.name),
                    relatedAccountId: from.id
                )
                _ = try self.db.addTransaction(txTo)
                
                DispatchQueue.main.async {
                    self.successMessage = String(format: "Успешно переведено %.2f %@ на счет %@", self.amount, from.currency, to.name)
                    self.isTransferComplete = true
                    self.isProcessing = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                }
            }
        }
    }
    
    // MARK: - Validation
    private func validate(accounts: [Account]) -> Bool {
        guard fromAccount != nil else {
            errorMessage = "Выберите счет отправителя"
            return false
        }
        
        guard toAccount != nil else {
            errorMessage = "Выберите счет получателя"
            return false
        }
        
        guard fromAccount?.id != toAccount?.id else {
            errorMessage = "Нельзя перевести на тот же счет"
            return false
        }
        
        guard amount >= 0.01 else {
            errorMessage = "Минимальная сумма перевода 0.01 BYN"
            return false
        }
        
        guard amount <= 10000 else {
            errorMessage = "Максимальная сумма перевода 10,000 BYN"
            return false
        }
        
        guard let from = fromAccount, from.availableBalance >= amount else {
            errorMessage = "Недостаточно средств на счете"
            return false
        }
        
        return true
    }
    
    // MARK: - Reset
    func reset() {
        fromAccount = nil
        toAccount = nil
        amountString = ""
        errorMessage = ""
        successMessage = ""
        isTransferComplete = false
        isProcessing = false
    }
}
