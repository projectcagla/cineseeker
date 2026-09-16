import SwiftUI
enum CineTheme {
    static let background = Color(red: 10/255, green: 10/255, blue: 10/255)
    static let surface = Color(red: 24/255, green: 24/255, blue: 26/255)
    static let accent = Color(red: 1, green: 0.48, blue: 0.16)
    static let gradient = LinearGradient(colors: [accent, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
}
