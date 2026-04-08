//
//  ProcessingSpinner.swift
//  ClaudeIsland
//
//  Animated yarn ball spinner for processing state
//

import Combine
import SwiftUI

// MARK: - Yarn Ball Spinner
struct ProcessingSpinner: View {
    @State private var rotation: Double = 0

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 2

            // Rotate the yarn ball pattern
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: .degrees(rotation))
            context.translateBy(x: -center.x, y: -center.y)

            // Draw yarn ball base (pink)
            let ballRect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            context.fill(Path(ellipse: ballRect), with: .color(Color(hex: "ffb6c1")))

            // Draw yarn wrap lines (darker pink) - 4 crossing lines
            let lineColor = Color(hex: "e89aa0")

            // Line 1
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: center.x - radius, y: center.y - radius * 0.3))
                    path.addLine(to: CGPoint(x: center.x + radius, y: center.y + radius * 0.3))
                },
                with: .color(lineColor),
                lineWidth: 1.5
            )

            // Line 2
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: center.x + radius, y: center.y - radius * 0.3))
                    path.addLine(to: CGPoint(x: center.x - radius, y: center.y + radius * 0.3))
                },
                with: .color(lineColor),
                lineWidth: 1.5
            )

            // Line 3 (horizontal-ish)
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: center.x - radius * 0.8, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + radius * 0.8, y: center.y))
                },
                with: .color(lineColor),
                lineWidth: 1.5
            )

            // Line 4 (vertical-ish)
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: center.x, y: center.y - radius * 0.8))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + radius * 0.8))
                },
                with: .color(lineColor),
                lineWidth: 1.5
            )

            // Draw yarn tail
            let tailPath = Path { path in
                path.move(to: CGPoint(x: center.x + radius * 0.7, y: center.y + radius * 0.7))
                path.addQuadCurve(
                    to: CGPoint(x: center.x + radius + 4, y: center.y + radius * 1.5),
                    control: CGPoint(x: center.x + radius + 6, y: center.y + radius * 0.9)
                )
            }
            context.stroke(tailPath, with: .color(Color(hex: "ffb6c1")), lineWidth: 2)
        }
        .frame(width: 20, height: 20)
        .onAppear {
            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ProcessingSpinner()
        .frame(width: 40, height: 40)
        .background(.black)
}
