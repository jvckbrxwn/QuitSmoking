//
//  MainView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State public var nsdController: NonSmokingDaysController
    var body: some View {
        VStack {
            Text("Non-smoking days:")
                .bold()
                .font(.system(size: 25))
            if nsdController.nonSmokingDays.isLoading {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 30)
                    .shimmer()
                    .padding(.top, 10)
            } else {
                Text("\(nsdController.nonSmokingDays.days)")
                    .bold()
                    .font(.system(size: 30))
                    .padding(.top, 10)
            }
        }
    }
}
