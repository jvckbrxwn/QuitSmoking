//
//  HomeView.swift
//  QuitSmoking
//
//  Created by Mac on 18.08.2025.
//

import SwiftUI

struct HomeView: View {
    var nsdController: NonSmokingDaysController
    @State private var showFireworks = false
    @State private var showSubtractConfirm = false
    @State private var showResetConfirm = false

    var body: some View {
        VStack(spacing: 20) {
            TopBarView(subtitle: nsdController.nonSmokingDays.days > 0 ? "You're doing great" : "Day one starts now")
                .padding(.top)
            Spacer()
            MainView(nsdController: nsdController)
                .padding()
            Spacer()
            BottomView(nsdController: nsdController, showFireworks: $showFireworks)
                .padding(.bottom)
        }
        .padding(.all)
        .padding(.bottom, 40)
        .overlay {
            FireworksView(isActive: $showFireworks)
                .ignoresSafeArea()
                .accessibilityHidden(true)
        }
        .sensoryFeedback(.success, trigger: nsdController.nonSmokingDays.days)
        .alert("Sync problem", isPresented: Binding(
            get: { nsdController.nonSmokingDays.lastError != nil },
            set: { if !$0 { nsdController.nonSmokingDays.lastError = nil } }
        )) { Button("OK", role: .cancel) {} } message: { Text(nsdController.nonSmokingDays.lastError ?? "") }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Subtract a Day") { showSubtractConfirm = true }
                    Button("Reset to Zero", role: .destructive) { showResetConfirm = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Subtract a day from your count?", isPresented: $showSubtractConfirm, titleVisibility: .visible) {
            Button("Subtract a Day") { Task { await nsdController.NegateNonSmokingDay() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This lowers your logged count by one.") }
        .confirmationDialog("Reset your count to zero?", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Reset to Zero", role: .destructive) { Task { await nsdController.ResetNonSmokingDays() } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This can't be undone.") }
    }
}
