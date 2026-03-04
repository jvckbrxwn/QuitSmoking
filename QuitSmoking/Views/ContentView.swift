//
//  ContentView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct ContentView: View {
    private var nsd = NonSmokingDaysController()
    var sessionHandler: SessionHandler

    init(sessionHandler: SessionHandler) {
        self.sessionHandler = sessionHandler
    }

    var body: some View {
        NavigationStack {
            TabView {
                // Tab 1
                HomeView(nsdController: nsd)
                    .navigationTitle("Home")
                    .tabItem{
                        Label("Home", systemImage: "house.fill")
                    }

                // Tab 2
                SettingsView(nsdController: nsd, sessionHandler: sessionHandler)
                    .navigationTitle("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
        }
        .task {
            await nsd.GetNonSmokingDays()
        }
        .onAppear {
            let saved = NotificationManager.shared.getSavedNotificationTime()
            NotificationManager.shared.rescheduleNotification(hour: saved.hour, minute: saved.minute)
        }
    }
    
}

#Preview {
    ContentView(sessionHandler: SessionHandler())
}
