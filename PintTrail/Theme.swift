import SwiftUI

enum PTTheme {
    // Core palette
    static let background = Color(red: 0.08, green: 0.06, blue: 0.05)       // near-black brown
    static let surface = Color(red: 0.14, green: 0.11, blue: 0.09)          // dark brown card
    static let surfaceLight = Color(red: 0.20, green: 0.16, blue: 0.13)     // lighter brown
    static let amber = Color(red: 0.89, green: 0.65, blue: 0.20)            // golden amber
    static let amberLight = Color(red: 0.95, green: 0.78, blue: 0.38)       // light gold
    static let amberDim = Color(red: 0.89, green: 0.65, blue: 0.20).opacity(0.3)
    static let cream = Color(red: 0.93, green: 0.89, blue: 0.82)            // warm white
    static let creamDim = Color(red: 0.93, green: 0.89, blue: 0.82).opacity(0.6)
    static let foam = Color(red: 0.96, green: 0.94, blue: 0.88)             // bright cream
    static let copper = Color(red: 0.72, green: 0.38, blue: 0.15)           // deep copper
    static let stout = Color(red: 0.12, green: 0.08, blue: 0.06)            // almost black
}

struct PTCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(PTTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PTScoreBadge: View {
    let score: String
    var size: Font = .title2

    var body: some View {
        Text(score)
            .font(size.bold())
            .foregroundStyle(PTTheme.amber)
            .shadow(color: PTTheme.amber.opacity(0.4), radius: 6)
    }
}

struct PTRankBadge: View {
    let rank: Int

    var body: some View {
        Text("#\(rank)")
            .font(.caption.bold())
            .foregroundStyle(PTTheme.cream)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(PTTheme.stout.opacity(0.85))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(PTTheme.amber.opacity(0.4), lineWidth: 1)
            )
    }
}

struct PTSectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption.bold())
            .foregroundStyle(PTTheme.amber)
            .tracking(1.5)
    }
}

extension View {
    func ptCard() -> some View {
        modifier(PTCardStyle())
    }
}
