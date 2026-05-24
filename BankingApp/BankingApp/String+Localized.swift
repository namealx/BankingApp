//
//  String+Localized.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation

extension String {
    var localized: String {
        LanguageBundle.current.localizedString(forKey: self, value: self, table: "Localizable")
    }
}
