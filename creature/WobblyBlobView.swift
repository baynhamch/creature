import SwiftUI

struct WobblyBlob: View {
    var emotion: Emotion
    var hunger: Int
    var age: Int
    private var sizeScale: CGFloat {
        return min(1.0 + CGFloat(age) * 0.01, 1.5)
    }
    @State private var phase: CGFloat = 0
    @State private var pulsate: Bool = false
    @State private var ripplePhase: CGFloat = 0.0
    @State private var edgePhase: CGFloat = 0.0

    private var gradientColors: [Color] {
        if hunger > 75 {
            return [.gray]
        }
        switch emotion {
        case .happy:
            return [.green]
        case .afraid:
            return [.purple, .indigo, .purple]
        default:
            return [.yellow]
        }
    }

    private var pulseDuration: Double {
        if hunger > 75 {
            return 3.0
        }
        switch emotion {
        case .happy: return 2.0
        case .afraid: return 0.5
        default: return 1.2
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .stroke(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.orange.opacity(0.4), Color.clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        ),
                        lineWidth: 4
                    ).scaleEffect(1.0 + 0.2 * CGFloat(sin(Double(ripplePhase))))
//                    .scaleEffect(1.0 + 0.1 * sin(ripplePhase))
                    .opacity(0.5 + 0.5 * CGFloat(sin(Double(ripplePhase))))
                    .animation(Animation.linear(duration: 2).repeatForever(autoreverses: true), value: ripplePhase)
                
                Path { path in
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    let radius: CGFloat = min(geo.size.width, geo.size.height) / 3
                    let waveStrength: CGFloat = 8 + 4 * sin(edgePhase)

                    path.move(to: CGPoint(x: center.x + radius, y: center.y))

                    for angle in stride(from: 0, to: CGFloat.pi * 2, by: .pi / 32) {
                        let x = center.x + (radius + sin(angle * 3 + phase) * waveStrength) * cos(angle)
                        let y = center.y + (radius + sin(angle * 3 + phase) * waveStrength) * sin(angle)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }

                    path.closeSubpath()
                }
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center
                    )
                )
                .animation(.easeInOut(duration: 1.0), value: emotion)
                .scaleEffect(pulsate ? 1.05 : 0.95)
                .animation(Animation.easeInOut(duration: pulseDuration).repeatForever(autoreverses: true), value: pulsate)
            }
        }
        .scaleEffect(sizeScale)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                phase += 0.02
                edgePhase += 0.01
                ripplePhase += 0.015
            }
            pulsate = true
        }
    }
}

#Preview {
    WobblyBlob(emotion: .happy, hunger: 0, age: 0)
}
