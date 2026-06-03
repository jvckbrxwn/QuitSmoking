//
//  SettingsView.swift
//  QuitSmoking
//
//  Created by Mac on 18.08.2025.
//

import FirebaseCore
import SwiftUI

struct SettingsView: View {
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
            DatePicker("Daily reminder", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .padding()
                .onChange(of: selectedTime) {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
                    let hour = components.hour ?? 20
                    let minute = components.minute ?? 30
                    NotificationManager.shared.saveNotificationTime(hour: hour, minute: minute)
                    NotificationManager.shared.rescheduleNotification(hour: hour, minute: minute)
                    Task {
                        await NotificationManager.shared.RequestPermissionInContext()
                    }
                }

            Spacer()
            Button("Sign Out") {
                signOut()
            }
            .padding()
            .controlSize(ControlSize.extraLarge)
            .buttonStyle(.bordered) // Or any style you prefer
        }
    }

    func signOut() {
        sessionHandler.signOut()
    }
}

#Preview {
    // SessionHandler() touches Auth.auth(); previews don't run @main's init,
    // so Firebase must be configured here (see CLAUDE.md: Firebase init order).
    if FirebaseApp.app() == nil { FirebaseApp.configure() }
    return SettingsView(sessionHandler: SessionHandler())
}
