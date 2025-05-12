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
        FirebaseApp.configure()
        return true
    }
}

@main
struct QuitSmokingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser != nil {
                ContentView().padding(20)
            } else {
                SignInWith().padding(20)
            }
        }
    }
}
