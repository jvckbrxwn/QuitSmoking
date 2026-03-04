//
//  SettingsView.swift
//  QuitSmoking
//
//  Created by Mac on 18.08.2025.
//

import SwiftUI

struct SettingsView: View {
    var nsdController: NonSmokingDaysController
    var sessionHandler: SessionHandler
    @State private var selectedTime: Date = {
        let saved = NotificationManager.shared.getSavedNotificationTime()
        var components = DateComponents()
        components.hour = saved.hour
        components.minute = saved.minute
        return Calendar.current.date(from: components) ?? Date()
    }()

    var body: some View {
        VStack {
            DatePicker("Update notification time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .padding()
                .onChange(of: selectedTime) {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
                    let hour = components.hour ?? 20
                    let minute = components.minute ?? 30
                    NotificationManager.shared.saveNotificationTime(hour: hour, minute: minute)
                    NotificationManager.shared.rescheduleNotification(hour: hour, minute: minute)
                }

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
    }

    func signOut() {
        sessionHandler.signOut()
    }
}

#Preview {
    SettingsView(nsdController: NonSmokingDaysController(), sessionHandler: SessionHandler())
}
