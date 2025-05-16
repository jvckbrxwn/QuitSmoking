//
//  NotificationService.swift
//  QuitSmoking
//
//  Created by Mac on 16.05.2025.
//
import Foundation
import SwiftUI
import UserNotifications

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self

        removeScheduledNotifications()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("🎯 Notification auth error: \(error.localizedDescription)")
                    } else {
                        print("🎯 Notification permission granted? \(granted)")
                    }
                }
            }
    }

    func removeScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        after seconds: TimeInterval
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: id,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🎯 Failed to schedule: \(error.localizedDescription)")
            } else {
                print("🎯 Scheduled \(id) in \(seconds)s")
            }
        }
    }

    // MARK: UNUserNotificationCenterDelegate

    /// Called when a notification arrives while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler
                                completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // Show banner even if app is open
        completionHandler([.banner, .sound])
    }

    /// Handle tap on notification (if you need custom behavior)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🎯 Tapped notification \(response.notification.request.identifier)")
        completionHandler()
    }
}

extension NotificationManager {
    /// Schedule a notification at the given hour and minute every day (or non-repeating if repeats = false).
    func scheduleDailyNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        hour: Int,
        minute: Int,
        repeats: Bool = true
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // 1️⃣ Build the date components for the trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        // 2️⃣ Create the calendar trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: repeats)

        let request = UNNotificationRequest(identifier: id,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🎯 Failed to schedule calendar notification: \(error.localizedDescription)")
            } else {
                let repeatText = repeats ? "every day" : "once"
                print("🎯 Scheduled \(id) at \(hour):\(String(format: "%02d", minute)) \(repeatText)")
            }
        }
    }
}
