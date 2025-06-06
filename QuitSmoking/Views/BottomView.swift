//
//  BottomView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//

import SwiftUI

struct BottomView: View {
    @State public var nsdController: NonSmokingDaysController

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        VStack {
            Text("Last tracking change date")
                .font(.caption)
                .bold()
                .foregroundStyle(.gray)

            Text("\(dateFormatter.string(from: nsdController.nonSmokingDays.lastTrackDate))")
                .font(.caption)
                .bold()
                .foregroundStyle(.gray)

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
                    Task {
                        await nsdController.NegateNonSmokingDay()
                    }
                })
            }
        }
        .onAppear {
            Task {
                let date = await nsdController.GetTrackingLastDate()
                print(dateFormatter.string(from: date))
            }
        }
    }

    func addNonSmokingDay() {
        print("You're awsome")
        Task {
            await nsdController.AddNonSmokingDay()
        }
    }
}
