//
//  HomeView.swift
//  QuitSmoking
//
//  Created by Mac on 18.08.2025.
//

import SwiftUI

struct HomeView: View {
    var nsdController: NonSmokingDaysController
    
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
        .padding(.bottom, 40)
    }
}
