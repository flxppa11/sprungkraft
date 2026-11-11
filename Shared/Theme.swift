import SwiftUI

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        if s.count != 6 { s = "1E6FF0" }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        self.init(red: Double((v >> 16) & 255) / 255, green: Double((v >> 8) & 255) / 255, blue: Double(v & 255) / 255)
    }
}

enum Theme {
    static var accent: Color = Color(hex: "1E6FF0")
    static var bg: Color = Color.white
    static var card: Color = Color(red: 0.95, green: 0.96, blue: 0.98)
    static var field: Color = Color(red: 0.91, green: 0.93, blue: 0.96)
    static var radius: CGFloat = 16
    static var dark: Bool = false

    /// bgStyle: 0 weiß, 1 hellgrau, 2 getönt, 3 dunkel
    static func apply(accentHex: String, bgStyle: Int, radius r: Int) {
        accent = Color(hex: accentHex)
        radius = CGFloat(r)
        dark = bgStyle == 3
        switch bgStyle {
        case 1:
            bg = Color(red: 0.94, green: 0.94, blue: 0.96); card = .white; field = Color(red: 0.90, green: 0.90, blue: 0.93)
        case 2:
            bg = Color(red: 0.94, green: 0.96, blue: 1.0); card = .white; field = Color(red: 0.88, green: 0.92, blue: 0.98)
        case 3:
            bg = Color(red: 0.05, green: 0.06, blue: 0.09); card = Color(red: 0.11, green: 0.12, blue: 0.16); field = Color(red: 0.17, green: 0.18, blue: 0.23)
        default:
            bg = .white; card = Color(red: 0.95, green: 0.96, blue: 0.98); field = Color(red: 0.91, green: 0.93, blue: 0.96)
        }
    }
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
