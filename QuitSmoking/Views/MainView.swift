//
//  MainView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State private var text = "Loading…"
    @State public var nsdController: NonSmokingDaysController
    var body: some View {
        VStack {
            Text("Non-smoking days:")
                .bold()
                .font(.system(size: 25))
            Text("\(nsdController.nonSmokingDays.days)")
                .bold()
                .font(.system(size: 30))
                .padding(.top, 10)
        }
    }
}
