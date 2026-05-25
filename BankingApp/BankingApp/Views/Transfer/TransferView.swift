//
//  TransferView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI
import Combine

struct TransferView: View {
    
    @EnvironmentObject var accountsVM: AccountsViewModel
    @EnvironmentObject var transferVM: TransferViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showSuccess = false
    
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
            Form {
                Section("from_account".localized) {
                    Picker("select_account".localized, selection: $transferVM.fromAccount) {
                        Text("select".localized).tag(Optional<Account>.none)
                        ForEach(accountsVM.accounts.filter { $0.isActive }) { account in
                            Text("\(account.name) — \(formatAmount(account.balance)) \(account.currency)")
                                .tag(Optional(account))
                        }
                    }
                    .disabled(transferVM.isProcessing)
                }
                
                Section("to_account".localized) {
                    Picker("select_account".localized, selection: $transferVM.toAccount) {
                        Text("select".localized).tag(Optional<Account>.none)
                        ForEach(accountsVM.accounts.filter { $0.isActive }) { account in
                            Text("\(account.name) — \(formatAmount(account.balance)) \(account.currency)")
                                .tag(Optional(account))
                        }
                    }
                    .disabled(transferVM.isProcessing)
                }
                
                Section("amount".localized) {
                    HStack {
                        TextField("0.00", text: $transferVM.amountString)
                            .keyboardType(.decimalPad)
                            .disabled(transferVM.isProcessing)
                    }
                    
                    if let fromAcc = transferVM.fromAccount {
                        let maxInCurrency = 10000.0 / rateToBYN(fromAcc.currency)
                        Text(String(format: "transfer_limits_fmt".localized, maxInCurrency, fromAcc.currency))
                            .font(.caption).foregroundColor(.secondary)
                    }
                    
                    if transferVM.isProcessing { ProgressView() }
                }
                
                if !transferVM.errorMessage.isEmpty {
                    Section { Text(transferVM.errorMessage).foregroundColor(.red) }
                }
                
                Section {
                    Button(action: performTransfer) {
                        HStack {
                            Spacer()
                            if transferVM.isProcessing {
                                ProgressView().tint(.white)
                            } else {
                                Text("transfer_button".localized).fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!isFormValid || transferVM.isProcessing)
                }
            }
            .navigationTitle("tab_transfer".localized)
            .alert("transfer_success_title".localized, isPresented: $showSuccess) {
                Button("ok".localized) {
                    transferVM.reset()
                    showSuccess = false
                }
            } message: {
                Text(transferVM.successMessage)
            }
            .onReceive(transferVM.$isTransferComplete) { completed in
                if completed && !transferVM.successMessage.isEmpty {
                    showSuccess = true
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        transferVM.fromAccount != nil && transferVM.toAccount != nil &&
        !transferVM.amountString.isEmpty && !transferVM.isProcessing
    }
    
    private func rateToBYN(_ currency: String) -> Double {
        let rates: [String: Double] = ["BYN":1.0,"USD":3.245,"EUR":3.512,"RUB":0.0362,"GBP":4.123,"CNY":0.449,"PLN":0.811]
        return rates[currency] ?? 1.0
    }
    
    private func performTransfer() {
        transferVM.onTransferSuccess = { newFrom, newTo, fromId, toId in
            accountsVM.updateAccountBalanceLocally(id: fromId, newBalance: newFrom)
            accountsVM.updateAccountBalanceLocally(id: toId, newBalance: newTo)
        }
        transferVM.performTransfer(accounts: accountsVM.accounts)
    }
}
