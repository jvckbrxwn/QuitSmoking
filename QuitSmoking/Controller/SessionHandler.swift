//
//  SessionHandler.swift
//  QuitSmoking
//
//  Created by Mac on 11.05.2025.
//

import FirebaseAuth
import Foundation

@Observable class SessionHandler {
    var isLoggedIn: Bool = false
    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isLoggedIn = user != nil
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }

        NotificationManager.shared.removeScheduledNotifications()

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "NonSmokingDays")
        defaults.removeObject(forKey: "TrackingLastDate")
    }
}
