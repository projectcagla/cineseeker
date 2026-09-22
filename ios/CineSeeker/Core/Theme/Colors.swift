import SwiftUI
enum CineTheme {
    static let background = Color(red: 10/255, green: 10/255, blue: 10/255)
    static let surface = Color(red: 24/255, green: 24/255, blue: 26/255)
    static let accent = Color(red: 1, green: 0.48, blue: 0.16)
    static let border = Color.white.opacity(0.09)
    static let success = Color(red: 0.40, green: 0.86, blue: 0.65)
    static let gradient = LinearGradient(colors: [accent, Color(red: 1, green: 0.77, blue: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
}
