//
//  NonSmokingDaysController.swift
//  QuitSmoking
//
//  Created by Mac on 11.05.2025.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI

class NonSmokingDaysController {
    private let valueKey = "NonSmokingDays"
    private let trackingLastDateKey = "TrackingLastDate"
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    private let userController = UserController()
    private let dateFormatter: DateFormatter = DateFormatter()

    @State var nonSmokingDays = NonSmokingDaysData()

    func GetNonSmokingDays() async {
        nonSmokingDays.days = defaults.integer(forKey: valueKey)
        let dateStr = defaults.string(forKey: trackingLastDateKey);
        nonSmokingDays.lastTrackDate = ((dateStr != nil) ? DateFormatter().date(from: dateStr!) : Date.now)!

        do {
            guard userController.GetUser().uid != "" else { return }
            let userUID = userController.GetUser().uid
            let snapshot = try await db.collection("users").document(userUID).getDocument()
            guard let days = snapshot.data()?[valueKey, default: 0] as? Int else { return }

            if nonSmokingDays.days != days {
                if nonSmokingDays.days < days {
                    nonSmokingDays.days = days
                }

                if nonSmokingDays.days > days {
                    _ = try await db.collection("users").document(userUID).setData([valueKey: nonSmokingDays.days])
                }
            }

        } catch {
            print("Can't update days from firebase firestore")
        }
    }

    func GetTrackingLastDate() async -> Date {
        do {
            guard userController.GetUser().uid != "" else { return Date.now }
            let userUID = userController.GetUser().uid
            let snapshot = try await db.collection("users").document(userUID).getDocument()
            let dateString = snapshot.data()?[trackingLastDateKey] as! Timestamp
            let date = dateString.dateValue()
            nonSmokingDays.lastTrackDate = date
            return nonSmokingDays.lastTrackDate
        } catch {
            return Date.now
        }
    }

    func SaveNonSmokingDays() async {
        nonSmokingDays.lastTrackDate = Date.now

        defaults.set(nonSmokingDays.days, forKey: valueKey)
        let dateStr = dateFormatter.string(from: nonSmokingDays.lastTrackDate)
        defaults.set(dateStr, forKey: trackingLastDateKey)

        do {
            guard userController.GetUser().uid != "" else { return }
            let userUID = userController.GetUser().uid
            _ = try await db.collection("users").document(userUID).setData([valueKey: nonSmokingDays.days, trackingLastDateKey: nonSmokingDays.lastTrackDate])
        } catch {
            print("Can't send data to firebase firestore")
        }
    }

    func ResetNonSmokingDays() async {
        nonSmokingDays.days = 0
        await SaveNonSmokingDays()
    }

    func AddNonSmokingDay() async {
        nonSmokingDays.days += 1
        await SaveNonSmokingDays()
    }

    func NegateNonSmokingDay() async {
        if nonSmokingDays.days > 0 {
            nonSmokingDays.days -= 1
        }
        await SaveNonSmokingDays()
    }
}
