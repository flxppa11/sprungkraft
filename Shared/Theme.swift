import SwiftUI

enum Theme {
    static let accent = Color(red: 0.83, green: 0.26, blue: 0.06)
}

struct ProgressRing: View {
    let done: Int
    let planned: Int

    var body: some View {
        let f: Double = planned > 0 ? min(1.0, Double(done) / Double(planned)) : 0
        ZStack {
            Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 10)
            Circle()
                .trim(from: 0, to: f)
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(done)/\(planned)")
                .font(.system(.title2, design: .rounded).bold())
        }
    }
}
