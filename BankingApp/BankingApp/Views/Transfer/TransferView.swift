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
    
    var body: some View {
        NavigationStack {
            Text("Transfer Screen")
                .navigationTitle("Перевод")
        }
    }
}
