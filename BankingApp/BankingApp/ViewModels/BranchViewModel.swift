//
//  BranchViewModel.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import CoreLocation
import MapKit
import Combine

// MARK: - BranchViewModel
final class BranchViewModel: ObservableObject {
    @Published var branches: [Branch] = []
    @Published var selectedBranch: Branch?
    @Published var nearestBranch: Branch?
    @Published var searchText: String = ""
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var filteredBranches: [Branch] { branches }
    
    func loadBranches() {
        
    }
    
    func findNearest() {
        
    }
    
    func openInMaps(_ branch: Branch) {
        
    }
    
    func centerMap(on branch: Branch) {
        selectedBranch = branch
    }
}
