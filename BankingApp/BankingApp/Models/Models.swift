//
//  Models.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation

// MARK: - AccountType
enum AccountType: String, CaseIterable, Codable {
    case current = "current"
    case savings = "savings"
    case credit = "credit"
    case card = "card"

    var localizedName: String {
        switch self {
        case .current: return "account_type_current".localized
        case .savings: return "account_type_savings".localized
        case .credit:  return "account_type_credit".localized
        case .card:    return "account_type_card".localized
        }
    }
}

// MARK: - CardSubtype
enum CardSubtype: String, CaseIterable, Codable {
    case savings = "savings"
    case credit = "credit"
}

// MARK: - Account
struct Account: Identifiable, Codable, Equatable, Hashable {
    var id: Int64
    var userId: Int64
    var name: String
    var type: AccountType
    var cardSubtype: CardSubtype?
    var currency: String
    var balance: Double
    var isActive: Bool
    var overdraftLimit: Double
    var createdAt: Date

    init(id: Int64 = 0, userId: Int64, name: String, type: AccountType,
         cardSubtype: CardSubtype? = nil, currency: String = "BYN",
         balance: Double = 0, isActive: Bool = true,
         overdraftLimit: Double = 0, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.cardSubtype = cardSubtype
        self.currency = currency
        self.balance = balance
        self.isActive = isActive
        self.overdraftLimit = overdraftLimit
        self.createdAt = createdAt
    }

    var hasOverdraft: Bool { overdraftLimit > 0 }
    var availableBalance: Double { balance + overdraftLimit }
}

// MARK: - TransactionType
enum TransactionType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
    case transfer = "transfer"

    var localizedName: String {
        switch self {
        case .income:   return "transaction_income".localized
        case .expense:  return "transaction_expense".localized
        case .transfer: return "transaction_transfer".localized
        }
    }
}

// MARK: - Transaction
struct Transaction: Identifiable, Codable {
    var id: Int64
    var accountId: Int64
    var type: TransactionType
    var amount: Double
    var currency: String
    var description: String
    var relatedAccountId: Int64?
    var createdAt: Date

    init(id: Int64 = 0, accountId: Int64, type: TransactionType,
         amount: Double, currency: String, description: String,
         relatedAccountId: Int64? = nil, createdAt: Date = Date()) {
        self.id = id
        self.accountId = accountId
        self.type = type
        self.amount = amount
        self.currency = currency
        self.description = description
        self.relatedAccountId = relatedAccountId
        self.createdAt = createdAt
    }
}

// MARK: - User
struct User: Identifiable, Codable {
    var id: Int64
    var fullName: String
    var email: String
    var phone: String
    var login: String
    var password: String
    var avatarData: Data?
    var createdAt: Date

    init(id: Int64 = 0, fullName: String, email: String, phone: String,
         login: String, password: String, avatarData: Data? = nil, createdAt: Date = Date()) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.login = login
        self.password = password
        self.avatarData = avatarData
        self.createdAt = createdAt
    }
}

// MARK: - Branch
struct Branch: Identifiable, Codable {
    var id: Int64
    var name: String
    var address: String
    var phone: String
    var workingHours: String
    var latitude: Double
    var longitude: Double
    var services: [String]
    var rating: Double

    init(id: Int64 = 0, name: String, address: String, phone: String,
         workingHours: String, latitude: Double, longitude: Double,
         services: [String] = [], rating: Double = 4.5) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.workingHours = workingHours
        self.latitude = latitude
        self.longitude = longitude
        self.services = services
        self.rating = rating
    }
}

// MARK: - CurrencyRate
struct CurrencyRate: Identifiable, Codable {
    var id: String { code }
    var code: String
    var name: String
    var rateToBYN: Double
    var rateToUSD: Double
    var changePercent: Double
    var isFavorite: Bool

    init(code: String, name: String, rateToBYN: Double, rateToUSD: Double,
         changePercent: Double = 0, isFavorite: Bool = false) {
        self.code = code
        self.name = name
        self.rateToBYN = rateToBYN
        self.rateToUSD = rateToUSD
        self.changePercent = changePercent
        self.isFavorite = isFavorite
    }
}
