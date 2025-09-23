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
                SettingsView(nsdController: nsd)
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
            NotificationManager.shared.scheduleDailyNotification(title: "Quit Smoking", body: "It's time to track you non-smoking day 🚭! You're doing great!", hour: 20, minute: 30, repeats: true)
        }
    }
    
    func Click() {
        print("Clicked to settings")
    }
}

#Preview {
    ContentView()
}
