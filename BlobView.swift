import SwiftUI

struct BlobView: View {
    @State private var time: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = min(size.width, size.height) * 0.3
            let segments = 60
            var path = Path()

            for i in 0..<segments {
                let angle = CGFloat(i) / CGFloat(segments) * 2 * .pi
                let wiggle = sin(angle * 8 + time * 2) * 10 + cos(angle * 5 + time * 1.5) * 6
                let adjustedRadius = radius + wiggle
                let x = center.x + adjustedRadius * cos(angle)
                let y = center.y + adjustedRadius * sin(angle)

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            path.closeSubpath()

            context.fill(path, with: .radialGradient(
                Gradient(colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.3), .clear]),
                center: center,
                startRadius: 0,
                endRadius: radius * 1.6
            ))
        }
        .background(Color.black)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                time += 0.02
            }
        }
    }

    private func updateTime(from date: Date) {
        let speed: CGFloat = 2.0
        time = CGFloat(date.timeIntervalSinceReferenceDate * speed)
    }
}

#Preview {
    BlobView()
}
