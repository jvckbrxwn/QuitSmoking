//
//  FireworksView.swift
//  QuitSmoking
//
//  Created by Mac on 04.03.2026.
//

import SwiftUI

struct Particle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var color: Color
    var opacity: Double
    var radius: CGFloat
    var lifetime: Double
    var maxLifetime: Double
}

@Observable
class FireworksViewModel {
    var particles: [Particle] = []
    private var lastUpdate: Date = .now

    private let colors: [Color] = [.red, .orange, .yellow, .purple, .cyan, .pink]

    func launch(in size: CGSize) {
        lastUpdate = .now

        let leftOrigin = CGPoint(x: 0, y: size.height)
        let rightOrigin = CGPoint(x: size.width, y: size.height)

        // Left corner — fans up-right
        for _ in 0..<70 {
            let angle = Double.random(in: -Double.pi / 2.5 ... -Double.pi / 6)
            let speed = CGFloat.random(in: 600...1000)
            let lifetime = Double.random(in: 1.2...2.5)
            particles.append(Particle(
                x: leftOrigin.x, y: leftOrigin.y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                color: colors.randomElement()!,
                opacity: 1.0,
                radius: CGFloat.random(in: 2...6),
                lifetime: lifetime,
                maxLifetime: lifetime
            ))
        }

        // Right corner — fans up-left
        for _ in 0..<70 {
            let angle = Double.random(in: -Double.pi + Double.pi / 6 ... -Double.pi + Double.pi / 2.5)
            let speed = CGFloat.random(in: 600...1000)
            let lifetime = Double.random(in: 1.2...2.5)
            particles.append(Particle(
                x: rightOrigin.x, y: rightOrigin.y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                color: colors.randomElement()!,
                opacity: 1.0,
                radius: CGFloat.random(in: 2...6),
                lifetime: lifetime,
                maxLifetime: lifetime
            ))
        }
    }

    func update(at currentDate: Date) {
        let dt = currentDate.timeIntervalSince(lastUpdate)
        lastUpdate = currentDate

        guard dt > 0, dt < 0.5 else { return }

        for i in particles.indices.reversed() {
            particles[i].x += particles[i].vx * dt
            particles[i].y += particles[i].vy * dt
            particles[i].vy += 450 * dt // gravity
            particles[i].lifetime -= dt
            particles[i].opacity = max(0, particles[i].lifetime / particles[i].maxLifetime)
            if particles[i].lifetime <= 0 {
                particles.remove(at: i)
            }
        }
    }
}

struct FireworksView: View {
    @Binding var isActive: Bool
    @State private var viewModel = FireworksViewModel()
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(paused: viewModel.particles.isEmpty && !isActive)) { timeline in
                Canvas { context, size in
                    viewModel.update(at: timeline.date)
                    for particle in viewModel.particles {
                        let rect = CGRect(
                            x: particle.x - particle.radius,
                            y: particle.y - particle.radius,
                            width: particle.radius * 2,
                            height: particle.radius * 2
                        )
                        context.opacity = particle.opacity
                        context.fill(Circle().path(in: rect), with: .color(particle.color))
                    }
                }
            }
            .onAppear {
                canvasSize = geo.size
            }
            .onChange(of: geo.size) { _, newSize in
                canvasSize = newSize
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { _, newValue in
            if newValue {
                viewModel.launch(in: canvasSize)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    isActive = false
                }
            }
        }
    }
}
