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
