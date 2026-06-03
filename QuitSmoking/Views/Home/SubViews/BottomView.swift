//
//  BottomView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//

import SwiftUI

struct BottomView: View {
    @State public var nsdController: NonSmokingDaysController
    @Binding var showFireworks: Bool
    @State private var showSameDayConfirm = false

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        VStack {
            if nsdController.nonSmokingDays.isLoading {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 14)
                    .shimmer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 14)
                    .shimmer()
            } else {
                Text("Last updated")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)

                Text("\(dateFormatter.string(from: nsdController.nonSmokingDays.lastTrackDate))")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
            }

            Button("Log a Day", action: addNonSmokingDay)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .bold()
                .disabled(nsdController.nonSmokingDays.isSaving || nsdController.nonSmokingDays.isLoading)
        }
        .confirmationDialog("You already logged today. Add another day?", isPresented: $showSameDayConfirm, titleVisibility: .visible) {
            Button("Add Another Day", action: logNonSmokingDay)
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            Task {
                let date = await nsdController.GetTrackingLastDate()
                print(dateFormatter.string(from: date))
            }
        }
    }

    func addNonSmokingDay() {
        // KNOWN LIMITATION: lastTrackDate updates on ANY save including Subtract/Reset,
        // so this confirm can occasionally appear after a same-day correction. Acceptable —
        // it only asks, never blocks (taps stay; backfill preserved).
        if Calendar.current.isDateInToday(nsdController.nonSmokingDays.lastTrackDate) && nsdController.nonSmokingDays.days > 0 {
            showSameDayConfirm = true
        } else {
            logNonSmokingDay()
        }
    }

    func logNonSmokingDay() {
        print("You're awsome")
        showFireworks = false
        DispatchQueue.main.async {
            showFireworks = true
        }
        Task {
            await nsdController.AddNonSmokingDay()
        }
    }
}
