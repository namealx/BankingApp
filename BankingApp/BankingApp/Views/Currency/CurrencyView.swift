//
//  CurrencyView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI

// MARK: - CurrencyView
struct CurrencyView: View {
    @EnvironmentObject var currencyVM: CurrencyViewModel
    
    var body: some View {
        NavigationStack {
            Text("Currency Rates Screen")
                .navigationTitle("Курсы валют")
        }
    }
}
