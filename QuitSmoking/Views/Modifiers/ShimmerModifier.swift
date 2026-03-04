//
//  ShimmerModifier.swift
//  QuitSmoking
//
//  Created by Mac on 04.03.2026.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.3), location: 0),
                        .init(color: .black.opacity(0.3), location: max(0, phase - 0.2)),
                        .init(color: .black, location: phase),
                        .init(color: .black.opacity(0.3), location: min(1, phase + 0.2)),
                        .init(color: .black.opacity(0.3), location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
