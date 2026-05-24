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
    @Published var fromAccount: Account?
    @Published var toAccount: Account?
    @Published var amountString: String = ""
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    @Published var isTransferComplete: Bool = false
    
    var amount: Double { Double(amountString) ?? 0 }
    
    func performTransfer(accounts: [Account]) {
        
    }
    
    func reset() {
        fromAccount = nil
        toAccount = nil
        amountString = ""
        errorMessage = ""
        successMessage = ""
        isTransferComplete = false
    }
}
