//
//  TransferView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI

// MARK: - TransferView
struct TransferView: View {
    
    @EnvironmentObject var accountsVM: AccountsViewModel
    @EnvironmentObject var transferVM: TransferViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: From Account Section
                Section("Со счета") {
                    Picker("Выберите счет", selection: $transferVM.fromAccount) {
                        Text("Выберите").tag(Optional<Account>.none)
                        ForEach(accountsVM.accounts.filter { $0.isActive }) { account in
                            Text("\(account.name) — \(String(format: "%.2f", account.balance)) \(account.currency)")
                                .tag(Optional(account))
                        }
                    }
                    .disabled(transferVM.isProcessing)
                    .accessibilityIdentifier("fromAccountPicker")
                }
                
                // MARK: To Account Section
                Section("На счет") {
                    Picker("Выберите счет", selection: $transferVM.toAccount) {
                        Text("Выберите").tag(Optional<Account>.none)
                        ForEach(accountsVM.accounts.filter { $0.isActive }) { account in
                            Text("\(account.name) — \(String(format: "%.2f", account.balance)) \(account.currency)")
                                .tag(Optional(account))
                        }
                    }
                    .disabled(transferVM.isProcessing)
                    .accessibilityIdentifier("toAccountPicker")
                }
                
                // MARK: Amount Section
                Section("Сумма") {
                    HStack {
                        TextField("0.00", text: $transferVM.amountString)
                            .keyboardType(.decimalPad)
                            .disabled(transferVM.isProcessing)
                            .accessibilityIdentifier("amountField")
                        
                        Text(transferVM.fromAccount?.currency ?? "BYN")
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                    
                    if let fromAcc = transferVM.fromAccount {
                        let minAmount = 0.01
                        let maxAmountBYN = 10000.0
                        let rate = rateToBYN(fromAcc.currency)
                        let maxInCurrency = maxAmountBYN / rate
                        
                        Text("Лимиты: от \(minAmount) до \(String(format: "%.2f", maxInCurrency)) \(fromAcc.currency)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Лимиты: от 0.01 до 10,000 BYN")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if transferVM.isProcessing {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    }
                }
                
                // MARK: Error Section
                if !transferVM.errorMessage.isEmpty {
                    Section {
                        Text(transferVM.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                // MARK: Transfer Button Section
                Section {
                    Button(action: performTransfer) {
                        HStack {
                            Spacer()
                            if transferVM.isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Перевести")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!isFormValid)
                    .accessibilityIdentifier("transferButton")
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Перевод")
            .alert("Перевод выполнен", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    transferVM.reset()
                }
            } message: {
                Text(transferVM.successMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        transferVM.fromAccount != nil &&
        transferVM.toAccount != nil &&
        !transferVM.amountString.isEmpty &&
        !transferVM.isProcessing
    }
    
    private var buttonColor: Color {
        isFormValid ? Color.blue : Color.gray
    }
    
    // MARK: - Helpers
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
    
    private func performTransfer() {
        transferVM.onTransferSuccess = {
            if let userId = authVM.currentUser?.id {
                accountsVM.loadAccounts(userId: userId)
            }
        }
        
        transferVM.performTransfer(accounts: accountsVM.accounts)
        
        if transferVM.isTransferComplete {
            showSuccess = true
        }
    }
}
