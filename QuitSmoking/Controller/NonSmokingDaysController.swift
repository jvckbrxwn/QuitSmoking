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
    private var valueKey = "NonSmokingDays"
    private var defaults = UserDefaults.standard
    private let userController = UserController()
    private let db = Firestore.firestore()

    @State var nonSmokingDays = NonSmokingDaysData()

    func RetriveNonSmokingDays() async {
        // firebase or maybe something else
        // try to get saved value
        // set to nonSmokingDaysData

        nonSmokingDays.days = defaults.integer(forKey: valueKey)

        do {
            guard userController.GetUser().uid != "" else { return }
            let userUID = userController.GetUser().uid
            let snapshot = try await db.collection("users").document(userUID).getDocument()
            guard let days = snapshot.data()?[valueKey] as? Int else { return }
            
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

    func SaveNonSmokingDays() async {
        defaults.set(nonSmokingDays.days, forKey: valueKey)

        do {
            guard userController.GetUser().uid != "" else { return }
            let userUID = userController.GetUser().uid
            _ = try await db.collection("users").document(userUID).setData([valueKey: nonSmokingDays.days])
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

    func GetNonSmokingDays() -> Int {
        return nonSmokingDays.days
    }
}
