//
//  ContentView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct ContentView: View {
    private var nsdController: NonSmokingDaysController = NonSmokingDaysController()

    var body: some View {
        VStack(spacing: 20) {
            TopBarView()
                .padding(.top)
            Spacer()
            MainView(nsdController: nsdController)
                .padding()
            Spacer()
            BottomView(nsdController: nsdController)
                .padding(.bottom)
        }
        .padding(.all)
        .task {
            await nsdController.GetNonSmokingDays()
        }
        .onAppear {
            NotificationManager.shared.scheduleDailyNotification(title: "Quit Smoking", body: "It's time to track you non-smoking day 🚭! You're doing great!", hour: 20, minute: 0, repeats: true)
        }
    }
}

#Preview {
    ContentView()
}
