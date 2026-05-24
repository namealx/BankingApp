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

final class BranchViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var branches: [Branch] = []
    @Published var selectedBranch: Branch?
    @Published var nearestBranch: Branch?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615)
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let db = DatabaseManager.shared
    private let locationManager = CLLocationManager()
    
    var filteredBranches: [Branch] {
        if searchText.isEmpty { return branches }
        return branches.filter {
            $0.address.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    override init() {
        super.init()
        setupLocationManager()
        loadBranches()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        // Запрашиваем разрешение сразу на главном потоке
        DispatchQueue.main.async {
            self.requestLocationPermission()
        }
    }
    
    // MARK: - Request Location Permission
    func requestLocationPermission() {
        print("🔄 Requesting location permission, status: \(locationManager.authorizationStatus.rawValue)")
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            self.errorMessage = "Доступ к геолокации запрещён. Включите в Настройках → BankingApp"
        default:
            break
        }
    }
    
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
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    func findNearestBranch() {
        let userCL: CLLocation
        if let location = locationManager.location {
            userCL = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            userCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        }
        
        nearestBranch = branches.min { a, b in
            let locA = CLLocation(latitude: a.latitude, longitude: a.longitude)
            let locB = CLLocation(latitude: b.latitude, longitude: b.longitude)
            return locA.distance(from: userCL) < locB.distance(from: userCL)
        }
    }
    
    func updateUserLocation(_ location: CLLocation) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.userLocation = location.coordinate
            self.mapRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            self.findNearestBranch()
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func openInMaps(_ branch: Branch) {
        let coordinate = CLLocationCoordinate2D(latitude: branch.latitude, longitude: branch.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = branch.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    func centerMap(on branch: Branch) {
        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: branch.latitude, longitude: branch.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        selectedBranch = branch
    }
    
    func centerMapOnUser() {
        if let location = locationManager.location {
            mapRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        } else {
            requestLocationPermission()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension BranchViewModel {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.locationAuthorizationStatus = status
        }
        print("📍 Authorization status changed: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.errorMessage = "Доступ к геолокации запрещён"
            }
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateUserLocation(location)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        
        if let clError = error as? CLError, clError.code == .denied {
            DispatchQueue.main.async {
                self.errorMessage = "Доступ к геолокации запрещён"
            }
        }
    }
}
