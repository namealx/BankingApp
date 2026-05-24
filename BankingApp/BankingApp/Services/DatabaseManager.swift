//
//  DatabaseManager.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import SQLite

// MARK: - DatabaseManager
final class DatabaseManager {
    
    // MARK: - Singleton
    static let shared = DatabaseManager()
    private var db: Connection?
    
    // MARK: - Tables
    private let usersTable = Table("users")
    private let accountsTable = Table("accounts")
    private let transactionsTable = Table("transactions")
    private let branchesTable = Table("branches")
    
    // MARK: - User Columns
    private let colId = Expression<Int64>("id")
    private let colFullName = Expression<String>("full_name")
    private let colEmail = Expression<String>("email")
    private let colPhone = Expression<String>("phone")
    private let colLogin = Expression<String>("login")
    private let colPassword = Expression<String>("password")
    private let colAvatarData = Expression<Data?>("avatar_data")
    private let colCreatedAt = Expression<Double>("created_at")
    
    // MARK: - Account Columns
    private let colUserId = Expression<Int64>("user_id")
    private let colName = Expression<String>("name")
    private let colType = Expression<String>("type")
    private let colCardSubtype = Expression<String?>("card_subtype")
    private let colBalance = Expression<Double>("balance")
    private let colCurrency = Expression<String>("currency")
    private let colIsActive = Expression<Bool>("is_active")
    private let colHasOverdraft = Expression<Bool>("has_overdraft")
    private let colOverdraftLimit = Expression<Double>("overdraft_limit")
    private let colAccountCreatedAt = Expression<Double>("created_at")
    
    // MARK: - Transaction Columns
    private let colAccountId = Expression<Int64>("account_id")
    private let colTxType = Expression<String>("type")
    private let colAmount = Expression<Double>("amount")
    private let colTxCurrency = Expression<String>("currency")
    private let colDescription = Expression<String>("description")
    private let colRelatedAccountId = Expression<Int64?>("related_account_id")
    private let colTxCreatedAt = Expression<Double>("created_at")
    
    // MARK: - Branch Columns
    private let colBranchId = Expression<Int64>("id")
    private let colBranchName = Expression<String>("name")
    private let colAddress = Expression<String>("address")
    private let colPhoneNum = Expression<String>("phone")
    private let colLatitude = Expression<Double>("latitude")
    private let colLongitude = Expression<Double>("longitude")
    private let colWorkingHours = Expression<String>("working_hours")
    private let colRating = Expression<Double>("rating")
    private let colServices = Expression<String>("services")
    
    // MARK: - Init
    private init() {
        setupDatabase()
    }
    
    // MARK: - Setup Database
    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/banking.sqlite3")
            createTables()
            insertDemoDataIfNeeded()
        } catch {
            print("DatabaseManager: connection error \(error)")
        }
    }
    
    // MARK: - Create Tables
    private func createTables() {
        guard let db = db else { return }
        do {
            // Users table
            try db.run(usersTable.create(ifNotExists: true) { t in
                t.column(colId, primaryKey: .autoincrement)
                t.column(colFullName)
                t.column(colEmail, unique: true)
                t.column(colPhone)
                t.column(colLogin, unique: true)
                t.column(colPassword)
                t.column(colAvatarData)
                t.column(colCreatedAt)
            })
            
            // Accounts table
            try db.run(accountsTable.create(ifNotExists: true) { t in
                t.column(colId, primaryKey: .autoincrement)
                t.column(colUserId)
                t.column(colName)
                t.column(colType)
                t.column(colCardSubtype)
                t.column(colBalance)
                t.column(colCurrency)
                t.column(colIsActive)
                t.column(colHasOverdraft)
                t.column(colOverdraftLimit)
                t.column(colAccountCreatedAt)
            })
            
            // Transactions table
            try db.run(transactionsTable.create(ifNotExists: true) { t in
                t.column(colId, primaryKey: .autoincrement)
                t.column(colAccountId)
                t.column(colTxType)
                t.column(colAmount)
                t.column(colTxCurrency)
                t.column(colDescription)
                t.column(colRelatedAccountId)
                t.column(colTxCreatedAt)
            })
            
            // Branches table
            try db.run(branchesTable.create(ifNotExists: true) { t in
                t.column(colBranchId, primaryKey: .autoincrement)
                t.column(colBranchName)
                t.column(colAddress)
                t.column(colPhoneNum)
                t.column(colLatitude)
                t.column(colLongitude)
                t.column(colWorkingHours)
                t.column(colRating)
                t.column(colServices)
            })
            
            print("✅ All tables created successfully")
        } catch {
            print("DatabaseManager: createTables error \(error)")
        }
    }
    
    // MARK: - Insert Demo Data
    private func insertDemoDataIfNeeded() {
        guard let db = db else { return }
        do {
            let count = try db.scalar(usersTable.count)
            guard count == 0 else { return }
            
            // Demo user
            let userId = try db.run(usersTable.insert(
                colFullName <- "Demo User",
                colEmail <- "demo@bank.com",
                colPhone <- "+375291234567",
                colLogin <- "demo",
                colPassword <- "demo123",
                colAvatarData <- nil,
                colCreatedAt <- Date().timeIntervalSince1970
            ))
            
            // Demo accounts
            let acc1 = try db.run(accountsTable.insert(
                colUserId <- userId,
                colName <- "Current Account",
                colType <- AccountType.current.rawValue,
                colCardSubtype <- nil,
                colBalance <- 1250.50,
                colCurrency <- "BYN",
                colIsActive <- true,
                colHasOverdraft <- false,
                colOverdraftLimit <- 0.0,
                colAccountCreatedAt <- Date().timeIntervalSince1970
            ))
            
            let acc2 = try db.run(accountsTable.insert(
                colUserId <- userId,
                colName <- "Savings Account",
                colType <- AccountType.savings.rawValue,
                colCardSubtype <- nil,
                colBalance <- 5000.0,
                colCurrency <- "BYN",
                colIsActive <- true,
                colHasOverdraft <- false,
                colOverdraftLimit <- 0.0,
                colAccountCreatedAt <- Date().timeIntervalSince1970
            ))
            
            let acc3 = try db.run(accountsTable.insert(
                colUserId <- userId,
                colName <- "USD Account",
                colType <- AccountType.current.rawValue,
                colCardSubtype <- nil,
                colBalance <- 300.0,
                colCurrency <- "USD",
                colIsActive <- true,
                colHasOverdraft <- false,
                colOverdraftLimit <- 0.0,
                colAccountCreatedAt <- Date().timeIntervalSince1970
            ))
            
            // Demo transactions
            let txData: [(Int64, String, Double, String, String)] = [
                (acc1, TransactionType.income.rawValue, 500.0, "BYN", "Salary"),
                (acc1, TransactionType.expense.rawValue, 120.50, "BYN", "Grocery"),
                (acc1, TransactionType.expense.rawValue, 45.0, "BYN", "Internet"),
                (acc2, TransactionType.income.rawValue, 1000.0, "BYN", "Transfer"),
                (acc2, TransactionType.income.rawValue, 4000.0, "BYN", "Savings deposit")
            ]
            for tx in txData {
                try db.run(transactionsTable.insert(
                    colAccountId <- tx.0,
                    colTxType <- tx.1,
                    colAmount <- tx.2,
                    colTxCurrency <- tx.3,
                    colDescription <- tx.4,
                    colRelatedAccountId <- nil,
                    colTxCreatedAt <- Date().timeIntervalSince1970
                ))
            }
            
            // Demo branches
            let branches: [(String, String, String, Double, Double, String, Double, String)] = [
                ("BankingApp Central", "вул. Леніна, 15, Мінск", "+375172001001", 53.9045, 27.5615, "09:00–18:00", 4.8, "ATM,Loans,Deposits,Currency"),
                ("BankingApp Niamiha", "вул. Нямiга, 8, Мінск", "+375172001002", 53.9102, 27.5489, "08:30–20:00", 4.6, "ATM,Loans,Cards"),
                ("BankingApp Kastrychnickaja", "пр. Незалежнасцi, 42, Мінск", "+375172001003", 53.8978, 27.5500, "09:00–17:00", 4.5, "ATM,Currency,Deposits"),
                ("BankingApp Partyzanski", "пр. Партызанскi, 70, Мінск", "+375172001004", 53.8850, 27.5900, "10:00–19:00", 4.3, "ATM,Loans")
            ]
            for b in branches {
                try db.run(branchesTable.insert(
                    colBranchName <- b.0,
                    colAddress <- b.1,
                    colPhoneNum <- b.2,
                    colLatitude <- b.3,
                    colLongitude <- b.4,
                    colWorkingHours <- b.5,
                    colRating <- b.6,
                    colServices <- b.7
                ))
            }
            
            print("✅ Demo data inserted successfully")
        } catch {
            print("DatabaseManager: insertDemoData error \(error)")
        }
    }
}

// MARK: - Database Error
enum DatabaseError: LocalizedError {
    case connectionFailed
    case insertFailed
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed: return "Database connection failed"
        case .insertFailed: return "Insert operation failed"
        case .notFound: return "Record not found"
        }
    }
}
