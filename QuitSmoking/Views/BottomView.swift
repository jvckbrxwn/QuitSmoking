//
//  BottomView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//

import SwiftUI

struct BottomView: View {
    @State public var nsdController: NonSmokingDaysController

    var body: some View {
        Button(action: addNonSmokingDay) {
            Text("Add days")
                .padding()
                .foregroundColor(.white)
                .bold()
        }
        .frame(width: 200, height: 50)
        .background(Color.purple)
        .clipShape(.buttonBorder)
        .shadow(color: .purple, radius: 15, y: 5)
        .contextMenu {
            Button("Reset Days", action: {
                Task {
                    await nsdController.ResetNonSmokingDays()
                }
            })
            
            Button("Negate day", action: {
                Task{
                    await nsdController.NegateNonSmokingDay()
                }
            })
        }
    }

    func addNonSmokingDay() {
        print("You're awsome")
        Task {
            await nsdController.AddNonSmokingDay()
        }
    }
}
