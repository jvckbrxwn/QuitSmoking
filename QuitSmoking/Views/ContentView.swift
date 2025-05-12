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
            await nsdController.RetriveNonSmokingDays()
        }
    }
}

#Preview {
    ContentView()
}
