//
//  TopBarView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//


import SwiftUI

struct TopBarView: View {
    var subtitle: String = "Track your smoke-free days"
    var body: some View{
        VStack{
            HStack{
                Image(systemName: "smoke.fill")
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)
                Text("Quit Smoking")
                    .font(.title)
                    .accessibilityAddTraits(.isHeader)
            }
            .bold()

            HStack{
                Image(systemName: "heart.rectangle")
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)
                Text(subtitle)
                    .font(.headline)
            }
        }.padding()
    }
}
