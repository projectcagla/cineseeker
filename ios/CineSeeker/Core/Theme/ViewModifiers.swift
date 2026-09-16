import SwiftUI
struct CineBackground: ViewModifier {
    func body(content: Content) -> some View { content.scrollContentBackground(.hidden).background(CineTheme.background) }
}
extension View { func cineBackground() -> some View { modifier(CineBackground()) } }
struct StatusPanel: View {
    let title: String
    let message: String
    var icon = "sparkles.tv"
    var retry: (() -> Void)? = nil
    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon).foregroundStyle(CineTheme.accent)
        } description: { Text(message) } actions: {
            if let retry { Button("Tekrar Dene", action: retry).buttonStyle(.borderedProminent) }
        }.padding(.vertical, 24)
    }
}
