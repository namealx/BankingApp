//
//  Models.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 22.05.2026
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

