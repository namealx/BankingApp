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
    @State private var showList = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // MARK: Map
                Map(coordinateRegion: $branchVM.mapRegion,
                    showsUserLocation: true,
                    userTrackingMode: .constant(.follow),
                    annotationItems: branchVM.filteredBranches) { branch in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: branch.latitude,
                        longitude: branch.longitude)) {
                        BranchAnnotationView(
                            branch: branch,
                            isNearest: branchVM.nearestBranch?.id == branch.id,
                            isSelected: branchVM.selectedBranch?.id == branch.id
                        )
                        .onTapGesture {
                            withAnimation {
                                branchVM.selectedBranch = branch
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    branchVM.loadBranches()
                }
                
                // MARK: Selected Branch Card
                if let branch = branchVM.selectedBranch {
                    BranchCardView(branch: branch) {
                        branchVM.openInMaps(branch)
                    }
                    .transition(.move(edge: .bottom))
                    .padding()
                }
            }
            .navigationTitle("Отделения")
            .toolbar {
                // List Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showList = true }) {
                        Image(systemName: "list.bullet")
                    }
                    .accessibilityIdentifier("branchListButton")
                }
                
                // Location Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { branchVM.centerMapOnUser() }) {
                        Image(systemName: "location.fill")
                    }
                }
            }
            .sheet(isPresented: $showList) {
                BranchListView()
                    .environmentObject(branchVM)
            }
            .alert("Ошибка", isPresented: .constant(!branchVM.errorMessage.isEmpty)) {
                Button("OK") { branchVM.errorMessage = "" }
            } message: {
                Text(branchVM.errorMessage)
            }
        }
    }
}

// MARK: - BranchAnnotationView
struct BranchAnnotationView: View {
    
    let branch: Branch
    let isNearest: Bool
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(annotationColor)
                    .frame(width: 36, height: 36)
                Image(systemName: "building.columns")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(annotationColor)
                .offset(y: -4)
        }
        .scaleEffect(isSelected ? 1.3 : 1.0)
        .animation(.spring(), value: isSelected)
    }
    
    private var annotationColor: Color {
        if isNearest { return .orange }
        if isSelected { return .blue }
        return .green
    }
}

// MARK: - BranchCardView
struct BranchCardView: View {
    
    let branch: Branch
    let onRoute: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(branch.name)
                        .font(.headline)
                    Text(branch.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", branch.rating))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            
            // Working Hours & Phone
            HStack {
                Label(branch.workingHours, systemImage: "clock")
                    .font(.caption)
                Spacer()
                Label(branch.phone, systemImage: "phone")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            // Services
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(branch.services, id: \.self) { service in
                        Text(service.trimmingCharacters(in: .whitespaces))
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
            
            // Route Button
            Button(action: onRoute) {
                Label("Проложить маршрут", systemImage: "arrow.triangle.turn.up.right.circle")
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("buildRouteButton")
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - BranchListView
struct BranchListView: View {
    
    @EnvironmentObject var branchVM: BranchViewModel
    @Environment(\.dismiss) var dismiss
    
    private func distanceString(for branch: Branch) -> String {
        guard let userLocation = branchVM.userLocation else {
            return "—"
        }
        let userCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let branchCL = CLLocation(latitude: branch.latitude, longitude: branch.longitude)
        let distance = userCL.distance(from: branchCL)
        
        if distance < 1000 {
            return "\(Int(distance)) м"
        } else {
            return String(format: "%.1f км", distance / 1000)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(branchVM.filteredBranches) { branch in
                Button(action: {
                    branchVM.centerMap(on: branch)
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(branch.name)
                                .font(.headline)
                            Spacer()
                            if branchVM.nearestBranch?.id == branch.id {
                                Text("Ближайшее")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                        Text(branch.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Label(branch.workingHours, systemImage: "clock")
                                .font(.caption)
                            Spacer()
                            Text(distanceString(for: branch))
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
                .accessibilityIdentifier("branchRow_\(branch.id)")
            }
            .searchable(text: $branchVM.searchText, prompt: "Поиск отделений...")
            .navigationTitle("Отделения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    BranchMapView()
        .environmentObject(BranchViewModel())
}
