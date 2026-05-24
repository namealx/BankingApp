//
//  MainTabView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 22.05.2026
//  Group: 12b
//

import SwiftUI

// MARK: - MainTabView
struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Accounts Screen")
                .tabItem {
                    Label("Счета", systemImage: "creditcard")
                }
            
            Text("Transfer Screen")
                .tabItem {
                    Label("Перевод", systemImage: "arrow.left.arrow.right")
                }
            
            Text("Currency Screen")
                .tabItem {
                    Label("Курсы", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            Text("Map Screen")
                .tabItem {
                    Label("Карта", systemImage: "map")
                }
            
            Text("Profile Screen")
                .tabItem {
                    Label("Профиль", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    MainTabView()
}

