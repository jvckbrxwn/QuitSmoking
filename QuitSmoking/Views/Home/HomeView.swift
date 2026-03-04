//
//  HomeView.swift
//  QuitSmoking
//
//  Created by Mac on 18.08.2025.
//

import SwiftUI

struct HomeView: View {
    var nsdController: NonSmokingDaysController
    @State private var showFireworks = false

    var body: some View {
        VStack(spacing: 20) {
            TopBarView()
                .padding(.top)
            Spacer()
            MainView(nsdController: nsdController)
                .padding()
            Spacer()
            BottomView(nsdController: nsdController, showFireworks: $showFireworks)
                .padding(.bottom)
        }
        .padding(.all)
        .padding(.bottom, 40)
        .overlay {
            if showFireworks {
                FireworksView(isActive: $showFireworks)
                    .ignoresSafeArea()
            }
        }
    }
}
