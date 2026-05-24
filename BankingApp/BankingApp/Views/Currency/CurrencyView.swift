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
    @State private var showConverter = false
    
    private func formatChangePercent(_ value: Double) -> String {
        return String(format: "%.2f%%", abs(value))
    }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: Converter Toggle
                Section {
                    Button(action: { showConverter.toggle() }) {
                        HStack {
                            Label("Конвертер валют", systemImage: "arrow.left.arrow.right")
                            Spacer()
                            Image(systemName: showConverter ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                        }
                    }
                    .accessibilityIdentifier("converterButton")
                }
                
                // MARK: Converter Section
                if showConverter {
                    Section {
                        // From Currency Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Из")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Из", selection: $currencyVM.converterFromCode) {
                                ForEach(currencyVM.rates, id: \.code) { rate in
                                    Text("\(rate.code) - \(rate.name)").tag(rate.code)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // To Currency Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("В")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("В", selection: $currencyVM.converterToCode) {
                                ForEach(currencyVM.rates, id: \.code) { rate in
                                    Text("\(rate.code) - \(rate.name)").tag(rate.code)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // Amount Input
                        HStack {
                            TextField("Сумма", text: $currencyVM.converterAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            
                            Text(currencyVM.converterFromCode)
                                .foregroundColor(.secondary)
                                .frame(width: 50)
                        }
                        
                        // Convert Button
                        Button(action: currencyVM.convert) {
                            Text("Конвертировать")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        // Result
                        if !currencyVM.converterResult.isEmpty {
                            HStack {
                                Text("Результат:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(currencyVM.converterResult) \(currencyVM.converterToCode)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                
                // MARK: Exchange Rates Section
                Section("Курсы валют") {
                    if currencyVM.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    } else {
                        ForEach(currencyVM.sortedRates) { rate in
                            CurrencyRateRowView(rate: rate) {
                                currencyVM.toggleFavorite(code: rate.code)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Курсы валют")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: currencyVM.refreshRates) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(currencyVM.isLoading)
                    .accessibilityIdentifier("refreshRatesButton")
                }
            }
            .refreshable {
                currencyVM.refreshRates()
            }
            .onAppear {
                if currencyVM.rates.isEmpty {
                    currencyVM.loadRates()
                }
            }
        }
    }
}

// MARK: - CurrencyRateRowView
struct CurrencyRateRowView: View {
    
    let rate: CurrencyRate
    let onToggleFavorite: () -> Void
    
    private func formatChangePercent(_ value: Double) -> String {
        return String(format: "%.2f%%", abs(value))
    }
    
    var body: some View {
        HStack {
            // Flag emoji (условный флаг по коду валюты)
            Text(flagForCurrency(rate.code))
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(rate.code)
                    .font(.headline)
                Text(rate.name)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.4f BYN", rate.rateToBYN))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(String(format: "%.4f USD", rate.rateToUSD))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 2) {
                    Image(systemName: rate.changePercent >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.caption2)
                        .foregroundColor(rate.changePercent >= 0 ? .green : .red)
                    Text(formatChangePercent(rate.changePercent))
                        .font(.caption2)
                        .foregroundColor(rate.changePercent >= 0 ? .green : .red)
                }
            }
            
            // Favorite Button
            Button(action: onToggleFavorite) {
                Image(systemName: rate.isFavorite ? "star.fill" : "star")
                    .foregroundColor(rate.isFavorite ? .yellow : .gray)
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("favoriteButton_\(rate.code)")
        }
        .padding(.vertical, 4)
    }
    
    private func flagForCurrency(_ code: String) -> String {
        switch code {
        case "USD": return "🇺🇸"
        case "EUR": return "🇪🇺"
        case "RUB": return "🇷🇺"
        case "BYN": return "🇧🇾"
        case "GBP": return "🇬🇧"
        case "CNY": return "🇨🇳"
        case "PLN": return "🇵🇱"
        default: return "🏦"
        }
    }
}

#Preview {
    CurrencyView()
        .environmentObject(CurrencyViewModel())
}
