//
//  QuitSmokingApp.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permission granted.")
            } else if let error = error {
                print("Permission denied: \(error.localizedDescription)")
            }
        }
        
        return true
    }
}

@main
struct QuitSmokingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var sessionHandler: SessionHandler

    init() {
        FirebaseApp.configure()
        _sessionHandler = State(initialValue: SessionHandler())
    }

    var body: some Scene {
        WindowGroup {
            if sessionHandler.isLoggedIn {
                ContentView(sessionHandler: sessionHandler).padding(20)
            } else {
                SignInWith().padding(20)
            }
        }
    }
}
