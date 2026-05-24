//
//  BranchMapView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI
import MapKit

struct BranchMapView: View {
    
    @EnvironmentObject var branchVM: BranchViewModel
    @State private var showList = false
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $branchVM.mapRegion,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
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
                                userTrackingMode = .none
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    branchVM.loadBranches()
                    branchVM.requestLocationPermission()
                }
                
                if let branch = branchVM.selectedBranch {
                    BranchCardView(branch: branch) {
                        branchVM.openInMaps(branch)
                    }
                    .transition(.move(edge: .bottom))
                    .padding()
                }
            }
            .navigationTitle("branches".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showList = true }) {
                        Image(systemName: "list.bullet")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        userTrackingMode = .follow
                        branchVM.centerMapOnUser()
                    }) {
                        Image(systemName: "location.fill")
                    }
                }
            }
            .sheet(isPresented: $showList) {
                BranchListView()
                    .environmentObject(branchVM)
            }
            .alert("error".localized, isPresented: .constant(!branchVM.errorMessage.isEmpty)) {
                Button("ok".localized) { branchVM.errorMessage = "" }
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
                    .frame(width: isNearest ? 42 : 36, height: isNearest ? 42 : 36)
                    .shadow(color: isNearest ? .orange.opacity(0.6) : .clear, radius: 6)
                Image(systemName: "building.columns")
                    .foregroundColor(.white)
                    .font(.system(size: isNearest ? 18 : 16, weight: isNearest ? .bold : .regular))
            }
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(annotationColor)
                .offset(y: -4)
        }
        .scaleEffect(isSelected ? 1.3 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
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
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(branch.name).font(.headline)
                    Text(branch.address).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", branch.rating))
                }
            }
            
            HStack {
                Label(branch.workingHours, systemImage: "clock").font(.caption)
                Spacer()
                Label(branch.phone, systemImage: "phone").font(.caption)
            }
            .foregroundColor(.secondary)
            
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
            
            Button(action: onRoute) {
                Label("build_route".localized, systemImage: "arrow.triangle.turn.up.right.circle")
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
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
    
    var body: some View {
        NavigationStack {
            List(branchVM.filteredBranches) { branch in
                Button {
                    withAnimation {
                        branchVM.centerMap(on: branch)
                    }
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(branch.name).font(.headline)
                            Spacer()
                            if branchVM.nearestBranch?.id == branch.id {
                                Text("nearest".localized)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                        Text(branch.address).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .searchable(text: $branchVM.searchText, prompt: "search_branch".localized)
            .navigationTitle("branches".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close".localized) { dismiss() }
                }
            }
        }
    }
}
