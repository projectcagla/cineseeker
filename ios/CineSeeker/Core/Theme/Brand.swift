import SwiftUI

/// The typographic C/slash sign used in the app icon.
struct CineMark: View {
    var body: some View {
        Text("C/").font(.system(size: 24, weight: .black)).tracking(-3)
            .foregroundStyle(CineTheme.background).frame(width: 40, height: 40)
            .background(.white).accessibilityHidden(true)
    }
}
struct BrandWordmark: View {
    var body: some View {
        HStack(spacing: 9) {
            Rectangle().fill(CineTheme.accent).frame(width: 4, height: 26)
            Text("CINE/SEEKER").font(.system(.headline, weight: .black)).tracking(-0.8)
        }.accessibilityElement(children: .ignore).accessibilityLabel("CineSeeker")
    }
}
struct CineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var prominent = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.subheadline, design: .monospaced, weight: .bold))
            .padding(.horizontal, 18).padding(.vertical, 15).frame(minHeight: 48)
            .foregroundStyle(prominent ? CineTheme.background : Color.white)
            .background(prominent ? Color.white : CineTheme.background)
            .overlay(Rectangle().strokeBorder(Color.white.opacity(prominent ? 1 : 0.4)))
            .opacity(!isEnabled ? 0.35 : configuration.isPressed ? 0.65 : 1)
    }
}
struct SectionHeading: View {
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle().fill(CineTheme.border).frame(height: 1).accessibilityHidden(true)
            Text(title).font(.cineHeading).tracking(-0.5)
            if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
        }
    }
}
struct EditorialEyebrow: View {
    let index: String
    let caption: String
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack { Text(index).foregroundStyle(CineTheme.accent); Spacer(minLength: 16); Text(caption).foregroundStyle(.secondary) }
            VStack(alignment: .leading, spacing: 8) { Text(index).foregroundStyle(CineTheme.accent); Text(caption).foregroundStyle(.secondary) }
        }.font(.cineLabel).tracking(1.5).padding(.bottom, 8)
            .overlay(alignment: .bottom) { Rectangle().fill(CineTheme.border).frame(height: 1) }
    }
}
struct FilterChip: View {
    let title: String
    var symbol: String? = nil
    let selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let symbol { Image(systemName: symbol) }
                Text(title)
            }.font(.system(.subheadline, design: .monospaced, weight: .semibold))
                .padding(.horizontal, 16).frame(minHeight: 44)
                .foregroundStyle(selected ? Color.black : .primary)
                .background(selected ? Color.white : CineTheme.background, in: Rectangle())
                .overlay(Rectangle().strokeBorder(selected ? Color.clear : CineTheme.border))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
    }
}
struct LoadingCards: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 24) {
            ForEach(0..<6, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    Rectangle().fill(CineTheme.surface).aspectRatio(2.0/3, contentMode: .fit)
                    Rectangle().fill(CineTheme.surface).frame(height: 13)
                    Rectangle().fill(CineTheme.surface).frame(width: 70, height: 10)
                }
            }
        }.accessibilityElement(children: .ignore).accessibilityLabel("İçerikler yükleniyor")
    }
}
struct MediaTypeControl: View {
    @Binding var selection: MediaType
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MediaType.allCases) { media in
                Button { selection = media; HapticManager.selection() } label: {
                    VStack(spacing: 12) {
                        Text(media.title.uppercased(with: Locale(identifier: "tr_TR")))
                            .font(.system(.subheadline, design: .monospaced, weight: .bold))
                            .foregroundStyle(selection == media ? .primary : .secondary)
                            .frame(maxWidth: .infinity, minHeight: 32)
                        Rectangle().fill(selection == media ? Color.white : CineTheme.border).frame(height: 2)
                    }
                }.buttonStyle(.plain).accessibilityAddTraits(selection == media ? .isSelected : [])
            }
        }.accessibilityElement(children: .contain).accessibilityLabel("İçerik türü")
    }
}
