//
//  Models.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: Int64
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

// MARK: - Account Type
enum AccountType: String, CaseIterable, Codable {
    case current = "current"
    case savings = "savings"
    case credit = "credit"
    case card = "card"

    var localizedName: String {
        switch self {
        case .current: return "Текущий"
        case .savings: return "Сберегательный"
        case .credit: return "Кредитный"
        case .card: return "Карта"
        }
    }
}

// MARK: - Card Account Subtype
enum CardSubtype: String, CaseIterable, Codable {
    case salary = "salary"
    case savings = "savings"
    case credit = "credit"
}

// MARK: - Account Model
struct Account: Identifiable, Codable, Hashable {
    let id: Int64
    let userId: Int64
    var name: String
    var type: AccountType
    var cardSubtype: CardSubtype?
    var balance: Double
    var currency: String
    var isActive: Bool
    var hasOverdraft: Bool
    var overdraftLimit: Double
    var createdAt: Date

    init(id: Int64 = 0, userId: Int64, name: String, type: AccountType,
         cardSubtype: CardSubtype? = nil, balance: Double = 0,
         currency: String = "BYN", isActive: Bool = true,
         hasOverdraft: Bool = false, overdraftLimit: Double = 0,
         createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.cardSubtype = cardSubtype
        self.balance = balance
        self.currency = currency
        self.isActive = isActive
        self.hasOverdraft = hasOverdraft
        self.overdraftLimit = overdraftLimit
        self.createdAt = createdAt
    }

    var availableBalance: Double {
        hasOverdraft ? balance + overdraftLimit : balance
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Transaction Type
enum TransactionType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
    case transfer = "transfer"

    var localizedName: String {
        switch self {
        case .income: return "Доход"
        case .expense: return "Расход"
        case .transfer: return "Перевод"
        }
    }
}

// MARK: - Transaction Model
struct Transaction: Identifiable, Codable {
    let id: Int64
    let accountId: Int64
    var type: TransactionType
    var amount: Double
    var currency: String
    var description: String
    var relatedAccountId: Int64?
    var createdAt: Date

    init(id: Int64 = 0, accountId: Int64, type: TransactionType,
         amount: Double, currency: String = "BYN", description: String,
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

// MARK: - Branch Model
struct Branch: Identifiable, Codable {
    let id: Int64
    var name: String
    var address: String
    var phone: String
    var latitude: Double
    var longitude: Double
    var workingHours: String
    var rating: Double
    var services: [String]

    init(id: Int64 = 0, name: String, address: String, phone: String,
         latitude: Double, longitude: Double, workingHours: String,
         rating: Double, services: [String]) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.latitude = latitude
        self.longitude = longitude
        self.workingHours = workingHours
        self.rating = rating
        self.services = services
    }
}

// MARK: - Currency Rate Model
struct CurrencyRate: Identifiable, Codable {
    let id: String
    var code: String
    var name: String
    var rateToBYN: Double
    var rateToUSD: Double
    var changePercent: Double
    var isFavorite: Bool

    init(code: String, name: String, rateToBYN: Double, rateToUSD: Double,
         changePercent: Double, isFavorite: Bool = false) {
        self.id = code
        self.code = code
        self.name = name
        self.rateToBYN = rateToBYN
        self.rateToUSD = rateToUSD
        self.changePercent = changePercent
        self.isFavorite = isFavorite
    }
}
