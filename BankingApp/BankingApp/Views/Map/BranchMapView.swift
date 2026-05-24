//
//  BranchMapView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI
import MapKit

// MARK: - BranchMapView
struct BranchMapView: View {
    @EnvironmentObject var branchVM: BranchViewModel
    
    var body: some View {
        NavigationStack {
            Text("Branches Map Screen")
                .navigationTitle("Отделения")
        }
    }
}
