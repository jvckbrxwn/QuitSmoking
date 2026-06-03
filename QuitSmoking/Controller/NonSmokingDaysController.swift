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
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df
    }()

    @State var nonSmokingDays = NonSmokingDaysData()

    func GetNonSmokingDays() async {
        nonSmokingDays.isLoading = true
        nonSmokingDays.days = defaults.integer(forKey: valueKey)
        let dateStr = defaults.string(forKey: trackingLastDateKey)
        nonSmokingDays.lastTrackDate = dateStr.flatMap { dateFormatter.date(from: $0) } ?? Date.now
        nonSmokingDays.isLoading = false

        do {
            guard userController.GetUser().uid != "" else {
                nonSmokingDays.isLoading = false
                return
            }
            let userUID = userController.GetUser().uid
            let snapshot = try await db.collection("users").document(userUID).getDocument()
            guard let days = snapshot.data()?[valueKey, default: 0] as? Int else {
                nonSmokingDays.isLoading = false
                return
            }

            if nonSmokingDays.days != days {
                if nonSmokingDays.days < days {
                    nonSmokingDays.days = days
                }

                if nonSmokingDays.days > days {
                    _ = try await db.collection("users").document(userUID).setData([valueKey: nonSmokingDays.days])
                }
            }

            if let ts = snapshot.get(trackingLastDateKey) as? Timestamp {   // get(_:) -> Any?  (FIRDocumentSnapshot.h:112)
                nonSmokingDays.lastTrackDate = ts.dateValue()               // (FIRTimestamp.h:63-64)
            }

        } catch {
            nonSmokingDays.lastError = "Couldn't sync with the cloud. Your count is saved on this device."
            print("Can't update days from firebase firestore")
        }
        nonSmokingDays.isLoading = false
    }

    func SaveNonSmokingDays() async {
        nonSmokingDays.isSaving = true
        nonSmokingDays.lastTrackDate = Date.now

        defaults.set(nonSmokingDays.days, forKey: valueKey)
        let dateStr = dateFormatter.string(from: nonSmokingDays.lastTrackDate)
        defaults.set(dateStr, forKey: trackingLastDateKey)

        do {
            guard userController.GetUser().uid != "" else {
                nonSmokingDays.isSaving = false
                return
            }
            let userUID = userController.GetUser().uid
            _ = try await db.collection("users").document(userUID).setData([valueKey: nonSmokingDays.days, trackingLastDateKey: nonSmokingDays.lastTrackDate])
        } catch {
            nonSmokingDays.lastError = "Couldn't sync with the cloud. Your count is saved on this device."
            print("Can't send data to firebase firestore")
        }
        nonSmokingDays.isSaving = false
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
