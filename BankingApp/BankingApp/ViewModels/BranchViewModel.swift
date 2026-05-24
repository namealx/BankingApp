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
    
    // MARK: - Published Properties
    @Published var branches: [Branch] = []
    @Published var selectedBranch: Branch?
    @Published var nearestBranch: Branch?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Location Properties
    @Published var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615)
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Dependencies
    private let db = DatabaseManager.shared
    private let locationManager = CLLocationManager()
    
    // MARK: - Computed Properties
    var filteredBranches: [Branch] {
        if searchText.isEmpty { return branches }
        return branches.filter {
            $0.address.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Init
    init() {
        setupLocationManager()
        loadBranches()
    }
    
    // MARK: - Location Manager Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Load Branches
    func loadBranches() {
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            do {
                let loadedBranches = try self?.db.getBranches() ?? []
                DispatchQueue.main.async {
                    self?.branches = loadedBranches
                    self?.isLoading = false
                    self?.findNearestBranch()
                    self?.addAnnotationsToMap()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Find Nearest Branch
    func findNearestBranch() {
        guard let userLocation = locationManager.location else { return }
        let userCL = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        nearestBranch = branches.min { a, b in
            let locA = CLLocation(latitude: a.latitude, longitude: a.longitude)
            let locB = CLLocation(latitude: b.latitude, longitude: b.longitude)
            return locA.distance(from: userCL) < locB.distance(from: userCL)
        }
    }
    
    // MARK: - Update User Location
    func updateUserLocation(_ location: CLLocation) {
        userLocation = location.coordinate
        mapRegion.center = location.coordinate
        findNearestBranch()
    }
    
    // MARK: - Add Annotations to Map
    private func addAnnotationsToMap() {
        objectWillChange.send()
    }
    
    // MARK: - Open in Maps
    func openInMaps(_ branch: Branch) {
        let coordinate = CLLocationCoordinate2D(latitude: branch.latitude, longitude: branch.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = branch.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    // MARK: - Center Map on Branch
    func centerMap(on branch: Branch) {
        withAnimation {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: branch.latitude, longitude: branch.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        selectedBranch = branch
    }
    
    // MARK: - Center Map on User Location
    func centerMapOnUser() {
        if let location = locationManager.location {
            withAnimation {
                mapRegion = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension BranchViewModel: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "Доступ к геолокации запрещен. Разрешите доступ в настройках."
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateUserLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Ошибка определения местоположения: \(error.localizedDescription)"
    }
}
