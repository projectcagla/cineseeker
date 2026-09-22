import SwiftUI

/// The film-splice monogram, shared with the vector identity and app icon.
struct CineMark: View {
    var body: some View {
        CineSymbol().fill(Color(red: 1, green: 133.0/255, blue: 52.0/255))
            .frame(width: 36, height: 38).accessibilityHidden(true)
    }
}
struct BrandWordmark: View {
    var body: some View {
        HStack(spacing: 7) {
            CineMark()
            Text("CineSeeker").font(.system(.headline, weight: .semibold)).tracking(-0.4)
        }.accessibilityElement(children: .ignore).accessibilityLabel("CineSeeker")
    }
}
struct SectionHeading: View {
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.cineHeading)
            if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
        }
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
            }.font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16).frame(minHeight: 44)
                .foregroundStyle(selected ? Color.black : .primary)
                .background(selected ? CineTheme.accent : CineTheme.surface, in: Capsule())
                .overlay(Capsule().strokeBorder(selected ? Color.clear : CineTheme.border))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
    }
}
struct LoadingCards: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 24) {
            ForEach(0..<6, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 18).fill(CineTheme.surface).aspectRatio(2.0/3, contentMode: .fit)
                    RoundedRectangle(cornerRadius: 4).fill(CineTheme.surface).frame(height: 13)
                    RoundedRectangle(cornerRadius: 4).fill(CineTheme.surface).frame(width: 70, height: 10)
                }
            }
        }.accessibilityElement(children: .ignore).accessibilityLabel("İçerikler yükleniyor")
    }
}
