//
//  TopBarView.swift
//  QuitSmoking
//
//  Created by Mac on 08.05.2025.
//


import SwiftUI

struct TopBarView: View {
    var body: some View{
        VStack{
            HStack{
                Image(systemName: "smoke.fill")
                    .foregroundStyle(.cyan)
                Text("Quit Smoking")
                    .font(.title)
            }
            .frame(width: 300, height: 50)
            .bold()
            
            HStack{
                Image(systemName: "heart.rectangle")
                    .foregroundStyle(.red)
                Text("You're doing great")
                    .font(.headline)
            }
            .frame(width: 300, height: 50)
        }.padding()
    }
}
