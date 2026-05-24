//
//  CurrencyViewModel.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import Combine

// MARK: - CurrencyViewModel
final class CurrencyViewModel: ObservableObject {
    @Published var rates: [CurrencyRate] = []
    @Published var isLoading: Bool = false
    @Published var converterFromCode: String = "USD"
    @Published var converterToCode: String = "BYN"
    @Published var converterAmount: String = "1"
    @Published var converterResult: String = ""
    
    func loadRates() {
        
    }
    
    func refreshRates() {
        loadRates()
    }
    
    func convert() {
        
    }
    
    func toggleFavorite(code: String) {
        
    }
    
    var sortedRates: [CurrencyRate] { rates }
}
