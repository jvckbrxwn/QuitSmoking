//
//  SettingsView.swift
//  QuitSmoking
//
//  Created by Mac on 18.08.2025.
//

import SwiftUI

struct SettingsView: View {
    var nsdController: NonSmokingDaysController
    
    var body: some View {
        DatePicker("Update notification time", selection: .constant(Date()), displayedComponents: .hourAndMinute)
            .padding()

        Spacer()
        Button("Sign Out") {
            // Call a function to handle the sign out process
            // authManager.signOut()
            // Optionally dismiss the current view
            // dismiss()

            signOut()
        }
        .padding()
        .controlSize(ControlSize.extraLarge)
        .buttonStyle(.bordered) // Or any style you prefer
        .tint(.blue)
    }

    func signOut() {
        print("Hello?")
    }
}

#Preview {
    SettingsView(nsdController: NonSmokingDaysController())
}
