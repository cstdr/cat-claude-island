//
//  StatusIcons.swift
//  ClaudeIsland
//
//  Pixel-art Gulu cat status icons with animations.
//  Gulu: black/gray/white stripes, white paws, white chest-to-mouth.
//

import SwiftUI
import Combine

// MARK: - Pixel Size
private let PIXEL_SIZE: CGFloat = 3

// MARK: - Colors (Gulu palette)
private enum PixelColor {
    static let black = Color(hex: "2a2a2a")
    static let gray = Color(hex: "5a5a5a")
    static let lightGray = Color(hex: "8a8a8a")
    static let white = Color(hex: "f5f5f5")
    static let pink = Color(hex: "ffb6c1")
}

// MARK: - Idle Icon (sleeping/loafing)
struct IdleCatIcon: View {
    let size: CGFloat
    @State private var breathOffset: CGFloat = 0

    init(size: CGFloat = 12) {
        self.size = size
    }

    var body: some View {
        Canvas { context, _ in
            let scale = size / 48
            context.scaleBy(x: scale, y: scale)

            func p(_ x: Int, _ y: Int, _ c: Color) {
                let rect = CGRect(
                    x: CGFloat(x) * PIXEL_SIZE,
                    y: CGFloat(y) * PIXEL_SIZE,
                    width: PIXEL_SIZE,
                    height: PIXEL_SIZE
                )
                context.fill(Path(rect), with: .color(c))
            }

            let b = Int(breathOffset)

            // body loaf
            for x in 2..<8 { p(x, 4 + b, PixelColor.gray) }
            for x in 1..<9 { p(x, 5 + b, PixelColor.gray); p(x, 6 + b, PixelColor.gray) }
            for x in 2..<8 { p(x, 7 + b, PixelColor.white) }
            // head
            p(3, 2 + b, PixelColor.gray); p(4, 2 + b, PixelColor.gray)
            p(5, 2 + b, PixelColor.gray); p(6, 2 + b, PixelColor.gray)
            p(2, 3 + b, PixelColor.black); p(3, 3 + b, PixelColor.black)
            p(6, 3 + b, PixelColor.black); p(7, 3 + b, PixelColor.black)
            // closed eyes
            for x in 3..<7 { p(x, 3 + b, PixelColor.black) }
            // nose
            p(4, 4 + b, PixelColor.pink); p(5, 4 + b, PixelColor.pink)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                breathOffset = 1
            }
        }
    }
}

// MARK: - Waiting Icon (sitting, looking)
struct WaitingCatIcon: View {
    let size: CGFloat
    @State private var tailWag: CGFloat = 0

    init(size: CGFloat = 12) {
        self.size = size
    }

    var body: some View {
        Canvas { context, _ in
            let scale = size / 48
            context.scaleBy(x: scale, y: scale)

            func p(_ x: Int, _ y: Int, _ c: Color) {
                let rect = CGRect(
                    x: CGFloat(x) * PIXEL_SIZE,
                    y: CGFloat(y) * PIXEL_SIZE,
                    width: PIXEL_SIZE,
                    height: PIXEL_SIZE
                )
                context.fill(Path(rect), with: .color(c))
            }

            let t = Int(tailWag)

            // tail
            p(1, 10 + t, PixelColor.black); p(1, 11 + t, PixelColor.black)
            p(2, 11 + t, PixelColor.black); p(1, 12 + t, PixelColor.black)

            // body sitting
            for x in 2..<8 { p(x, 5, PixelColor.gray) }
            for x in 1..<9 { p(x, 6, PixelColor.gray); p(x, 7, PixelColor.gray) }
            for x in 3..<7 { p(x, 7, PixelColor.white) }

            // head
            for x in 2..<8 { p(x, 2, PixelColor.gray) }
            for x in 1..<9 { p(x, 3, PixelColor.black) }

            // ears
            p(2, 1, PixelColor.black); p(7, 1, PixelColor.black)

            // eyes
            p(3, 3, PixelColor.black); p(4, 3, PixelColor.white)
            p(5, 3, PixelColor.black)
            p(6, 3, PixelColor.white); p(7, 3, PixelColor.black)

            // nose
            p(4, 4, PixelColor.pink); p(5, 4, PixelColor.pink)

            // paws
            p(2, 8, PixelColor.white); p(3, 8, PixelColor.white)
            p(6, 8, PixelColor.white); p(7, 8, PixelColor.white)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                tailWag = tailWag == 0 ? 1 : 0
            }
        }
    }
}

// MARK: - Running Icon (v6: white triangle face, pink square nose)
struct RunningCatIcon: View {
    let size: CGFloat
    @State private var frame: Int = 0
    @State private var timerCancellable: AnyCancellable?

    init(size: CGFloat = 12) {
        self.size = size
    }

    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 32
            context.scaleBy(x: scale, y: scale)

            func px(_ x: Int, _ y: Int, _ c: Color) {
                let rect = CGRect(x: CGFloat(x - 4), y: CGFloat(y - 3), width: 1, height: 1)
                context.fill(Path(rect), with: .color(c))
            }

            let G = PixelColor.gray
            let B = PixelColor.black
            let W = PixelColor.white
            let P = PixelColor.pink
            let D = PixelColor.lightGray

            switch frame {
            case 0:
                for x in 18..<24 { px(x, 6, G); px(x, 11, G) }
                for x in 17..<25 { px(x, 7, G); px(x, 8, G); px(x, 9, G); px(x, 10, G) }
                px(20, 8, W); px(21, 8, W)
                px(19, 9, W); px(20, 9, W); px(21, 9, W); px(22, 9, W)
                for x in 18..<24 { px(x, 10, W); px(x, 11, W); }
                px(20, 9, P); px(21, 9, P)
                px(20, 10, P); px(21, 10, P)
                px(18, 7, B); px(23, 7, B)
                px(17, 5, B); px(18, 5, B)
                px(16, 4, B); px(17, 4, B); px(18, 4, B)
                px(24, 5, B); px(25, 5, B)
                px(24, 4, B); px(25, 4, B); px(26, 4, B)
                for x in 10..<18 { px(x, 11, G); px(x, 12, G); px(x, 13, G) }
                px(14, 12, W); px(15, 12, W); px(16, 12, W)
                px(14, 13, W); px(15, 13, W); px(16, 13, W)
                px(11, 11, D); px(15, 11, D)
                px(8, 10, B); px(7, 9, B); px(6, 8, B); px(5, 7, B); px(4, 6, B)
                px(18, 14, W); px(19, 14, W)
                px(19, 15, W); px(20, 15, W)
                px(18, 16, W); px(19, 16, W)
                px(10, 16, W); px(11, 16, W)
                px(9, 17, W); px(10, 17, W)
                px(8, 18, W); px(9, 18, W)

            case 1:
                for x in 18..<24 { px(x, 6, G); px(x, 11, G) }
                for x in 17..<25 { px(x, 7, G); px(x, 8, G); px(x, 9, G); px(x, 10, G) }
                px(20, 8, W); px(21, 8, W)
                px(19, 9, W); px(20, 9, W); px(21, 9, W); px(22, 9, W)
                for x in 18..<24 { px(x, 10, W); px(x, 11, W); }
                px(20, 9, P); px(21, 9, P)
                px(20, 10, P); px(21, 10, P)
                px(18, 7, B); px(23, 7, B)
                px(17, 5, B); px(18, 5, B)
                px(16, 4, B); px(17, 4, B); px(18, 4, B)
                px(24, 5, B); px(25, 5, B)
                px(24, 4, B); px(25, 4, B); px(26, 4, B)
                for x in 10..<18 { px(x, 11, G); px(x, 12, G); px(x, 13, G) }
                px(14, 12, W); px(15, 12, W); px(16, 12, W)
                px(14, 13, W); px(15, 13, W); px(16, 13, W)
                px(11, 11, D); px(15, 11, D)
                px(8, 10, B); px(7, 9, B); px(6, 8, B); px(5, 7, B); px(4, 6, B)
                px(18, 15, W); px(19, 15, W)
                px(19, 16, W); px(20, 16, W)
                px(18, 17, W); px(19, 17, W)
                px(10, 15, W); px(11, 15, W)
                px(9, 16, W); px(10, 16, W)
                px(8, 17, W); px(9, 17, W)

            case 2:
                for x in 18..<24 { px(x, 6, G); px(x, 11, G) }
                for x in 17..<25 { px(x, 7, G); px(x, 8, G); px(x, 9, G); px(x, 10, G) }
                px(20, 8, W); px(21, 8, W)
                px(19, 9, W); px(20, 9, W); px(21, 9, W); px(22, 9, W)
                for x in 18..<24 { px(x, 10, W); px(x, 11, W); }
                px(20, 9, P); px(21, 9, P)
                px(20, 10, P); px(21, 10, P)
                px(18, 7, B); px(23, 7, B)
                px(17, 5, B); px(18, 5, B)
                px(16, 4, B); px(17, 4, B); px(18, 4, B)
                px(24, 5, B); px(25, 5, B)
                px(24, 4, B); px(25, 4, B); px(26, 4, B)
                for x in 10..<18 { px(x, 11, G); px(x, 12, G); px(x, 13, G) }
                px(14, 12, W); px(15, 12, W); px(16, 12, W)
                px(14, 13, W); px(15, 13, W); px(16, 13, W)
                px(11, 11, D); px(15, 11, D)
                px(8, 10, B); px(7, 9, B); px(6, 8, B); px(5, 7, B); px(4, 6, B)
                px(16, 16, W); px(17, 16, W)
                px(15, 17, W); px(16, 17, W)
                px(14, 18, W); px(15, 18, W)
                px(12, 14, W); px(13, 14, W)
                px(13, 15, W); px(14, 15, W)
                px(12, 16, W); px(13, 16, W)

            default:
                for x in 18..<24 { px(x, 6, G); px(x, 11, G) }
                for x in 17..<25 { px(x, 7, G); px(x, 8, G); px(x, 9, G); px(x, 10, G) }
                px(20, 8, W); px(21, 8, W)
                px(19, 9, W); px(20, 9, W); px(21, 9, W); px(22, 9, W)
                for x in 18..<24 { px(x, 10, W); px(x, 11, W); }
                px(20, 9, P); px(21, 9, P)
                px(20, 10, P); px(21, 10, P)
                px(18, 7, B); px(23, 7, B)
                px(17, 5, B); px(18, 5, B)
                px(16, 4, B); px(17, 4, B); px(18, 4, B)
                px(24, 5, B); px(25, 5, B)
                px(24, 4, B); px(25, 4, B); px(26, 4, B)
                for x in 10..<18 { px(x, 11, G); px(x, 12, G); px(x, 13, G) }
                px(14, 12, W); px(15, 12, W); px(16, 12, W)
                px(14, 13, W); px(15, 13, W); px(16, 13, W)
                px(11, 11, D); px(15, 11, D)
                px(8, 10, B); px(7, 9, B); px(6, 8, B); px(5, 7, B); px(4, 6, B)
                px(17, 15, W); px(18, 15, W)
                px(18, 16, W); px(19, 16, W)
                px(17, 17, W); px(18, 17, W)
                px(11, 15, W); px(12, 15, W)
                px(10, 16, W); px(11, 16, W)
                px(9, 17, W); px(10, 17, W)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            timerCancellable = Timer.publish(every: 0.12, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    frame = (frame + 1) % 4
                }
        }
        .onDisappear {
            timerCancellable?.cancel()
        }
    }
}

// MARK: - Approval Icon (paw raised)
struct ApprovalCatIcon: View {
    let size: CGFloat
    @State private var pawBob: CGFloat = 0

    init(size: CGFloat = 12) {
        self.size = size
    }

    var body: some View {
        Canvas { context, _ in
            let scale = size / 48
            context.scaleBy(x: scale, y: scale)

            func p(_ x: Int, _ y: Int, _ c: Color) {
                let rect = CGRect(
                    x: CGFloat(x) * PIXEL_SIZE,
                    y: CGFloat(y) * PIXEL_SIZE,
                    width: PIXEL_SIZE,
                    height: PIXEL_SIZE
                )
                context.fill(Path(rect), with: .color(c))
            }

            let bob = Int(pawBob)

            // body
            for x in 2..<8 { p(x, 6, PixelColor.gray) }
            for x in 1..<9 { p(x, 7, PixelColor.gray); p(x, 8, PixelColor.gray) }
            for x in 3..<7 { p(x, 8, PixelColor.white) }

            // head
            for x in 2..<8 { p(x, 2, PixelColor.gray) }
            for x in 1..<9 { p(x, 3, PixelColor.black) }
            p(2, 1, PixelColor.black); p(7, 1, PixelColor.black)

            // eyes
            p(3, 3, PixelColor.black); p(4, 3, PixelColor.white)
            p(5, 3, PixelColor.black)
            p(6, 3, PixelColor.black)

            // nose
            p(4, 4, PixelColor.pink); p(5, 4, PixelColor.pink)

            // raised paw
            p(8, 2 + bob, PixelColor.white); p(9, 2 + bob, PixelColor.white)
            p(9, 1 + bob, PixelColor.white)

            // paws
            p(2, 9, PixelColor.white); p(3, 9, PixelColor.white)
            p(6, 9, PixelColor.white); p(7, 9, PixelColor.white)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                pawBob = pawBob == 0 ? -1 : 0
            }
        }
    }
}

// MARK: - Status Icon View (unified)
struct StatusIcon: View {
    let phase: SessionPhase
    let size: CGFloat

    init(phase: SessionPhase, size: CGFloat = 12) {
        self.phase = phase
        self.size = size
    }

    var body: some View {
        switch phase {
        case .waitingForInput:
            WaitingCatIcon(size: size)
        case .waitingForApproval:
            ApprovalCatIcon(size: size)
        case .processing, .compacting:
            RunningCatIcon(size: size)
        case .idle, .ended:
            IdleCatIcon(size: size)
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

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 30) {
            VStack {
                IdleCatIcon(size: 48)
                Text("idle").font(.caption)
            }
            VStack {
                WaitingCatIcon(size: 48)
                Text("waiting").font(.caption)
            }
            VStack {
                RunningCatIcon(size: 48)
                Text("running").font(.caption)
            }
            VStack {
                ApprovalCatIcon(size: 48)
                Text("approval").font(.caption)
            }
        }
    }
    .padding()
    .background(Color.black)
}
