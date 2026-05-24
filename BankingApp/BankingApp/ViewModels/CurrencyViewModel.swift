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
    
    // MARK: - Published Properties
    @Published var rates: [CurrencyRate] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Converter Properties
    @Published var converterFromCode: String = "USD"
    @Published var converterToCode: String = "BYN"
    @Published var converterAmount: String = "100"
    @Published var converterResult: String = ""
    
    // MARK: - Dependencies
    private let settings = SettingsManager.shared
    
    // MARK: - Computed Properties
    var sortedRates: [CurrencyRate] {
        let favorites = rates.filter { $0.isFavorite }
        let regular = rates.filter { !$0.isFavorite }
        return favorites + regular
    }
    
    // MARK: - Load Rates
    func loadRates() {
        isLoading = true
        errorMessage = ""
        
        let baseRates: [(code: String, nameKey: String, rateToBYN: Double, rateToUSD: Double)] = [
            ("BYN", "currency_byn", 1.0, 0.308),
            ("USD", "currency_usd", 3.245, 1.0),
            ("EUR", "currency_eur", 3.512, 1.082),
            ("RUB", "currency_rub", 0.0362, 0.01115),
            ("GBP", "currency_gbp", 4.123, 1.270),
            ("CNY", "currency_cny", 0.449, 0.1384),
            ("PLN", "currency_pln", 0.811, 0.250)
        ]
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let loadedRates = baseRates.map { data in
                CurrencyRate(
                    code: data.code,
                    name: data.nameKey.localized,
                    rateToBYN: data.rateToBYN,
                    rateToUSD: data.rateToUSD,
                    changePercent: Double.random(in: -2.0...2.0),
                    isFavorite: self.settings.favoriteCurrencies.contains(data.code)
                )
            }
            
            DispatchQueue.main.async {
                self.rates = loadedRates
                self.isLoading = false
                self.convert()
            }
        }
    }
    
    // MARK: - Refresh Rates
    func refreshRates() {
        loadRates()
    }
    
    // MARK: - Favorites
    func toggleFavorite(code: String) {
        settings.toggleFavoriteCurrency(code)
        
        if let index = rates.firstIndex(where: { $0.code == code }) {
            rates[index].isFavorite.toggle()
            objectWillChange.send()
        }
    }
    
    // MARK: - Converter
    func convert() {
        guard let amount = Double(converterAmount.replacingOccurrences(of: ",", with: ".")),
              let from = rates.first(where: { $0.code == converterFromCode }),
              let to = rates.first(where: { $0.code == converterToCode }) else {
            converterResult = ""
            return
        }
        
        let inBYN = amount * from.rateToBYN
        let result = inBYN / to.rateToBYN
        converterResult = String(format: "%.4f", result)
    }
    
    // MARK: - Helpers
    func getRateString(for code: String) -> String {
        guard let rate = rates.first(where: { $0.code == code }) else { return "—" }
        return String(format: "%.4f BYN", rate.rateToBYN)
    }
}
