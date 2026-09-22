import SwiftUI

struct PersonDetailView: View {
    let person: Person
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var model: PersonViewModel
    @State private var expandedBiography = false
    init(person: Person, role: FilmographyRole = .all) {
        self.person = person
        _model = State(initialValue: PersonViewModel(role: role))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                EditorialEyebrow(index: "PORTRE", caption: "KAMERANIN İKİ YANI")
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .bottom, spacing: 24) { portrait; identity }
                    VStack(alignment: .leading, spacing: 20) { portrait; identity }
                }
                if let biography = model.biography {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeading(title: "Bir hayat, birçok hikâye")
                        if model.biographyIsEnglish { Text("İngilizce biyografi · Türkçe metin bulunmuyor").font(.cineLabel).foregroundStyle(.secondary) }
                        Text(biography).font(.body).lineSpacing(5).foregroundStyle(.secondary)
                            .lineLimit(expandedBiography ? nil : 5).textSelection(.enabled)
                        Button(expandedBiography ? "Daha az göster" : "Biyografinin tamamı") { expandedBiography.toggle() }
                            .font(.subheadline).frame(minHeight: 44)
                    }
                }
                if let error = model.error {
                    StatusPanel(title: "Portre yüklenemedi", message: error, icon: "wifi.exclamationmark") { Task { await model.load(id: person.id) } }
                }
                if model.loading && model.profile == nil { ProgressView("Filmografi yükleniyor…").frame(maxWidth: .infinity).padding(32) }
                if model.profile != nil {
                    filmography
                }
                Text("Biyografi ve filmografi: TMDB. Yayın seçenekleri her yapımın detayında gösterilir.")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(20).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.cineBackground().navigationTitle(person.name).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ShareLink(item: URL(string: "https://www.themoviedb.org/person/\(person.id)")!) {
                    Image(systemName: "square.and.arrow.up")
                }.accessibilityLabel("Kişiyi paylaş")
            }
            .task(id: person.id) { await model.load(id: person.id) }
            .refreshable { await model.load(id: person.id) }
    }
    private var portrait: some View {
        PosterImage(path: model.profile?.profilePath ?? person.profilePath, size: "w342")
            .frame(width: 136, height: 184).saturation(0)
            .overlay(alignment: .bottomLeading) { Rectangle().fill(CineTheme.accent).frame(width: 40, height: 3) }
            .accessibilityHidden(true)
    }
    private var identity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.profile?.name ?? person.name).font(.cineEditorial).fixedSize(horizontal: false, vertical: true)
            if let place = model.profile?.placeOfBirth?.nonEmpty { Text(place).font(.subheadline).foregroundStyle(.secondary) }
            if let birthday = model.profile?.birthday?.nonEmpty {
                Text([formattedDate(birthday), model.profile?.deathday?.nonEmpty.map { formattedDate($0) }].compactMap { $0 }.joined(separator: " — "))
                    .font(.cineLabel).foregroundStyle(.secondary)
            }
            if !model.entries.isEmpty {
                Text("\(model.entries.count) YAPIM").font(.cineLabel).tracking(2).foregroundStyle(CineTheme.accent)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    private var filmography: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeading(title: "Filmografi", subtitle: "Bir isimden başka bir hikâyeye.")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "Tümü", selected: model.media == nil) { model.media = nil }
                    ForEach(MediaType.allCases) { media in
                        FilterChip(title: media.title, selected: model.media == media) { model.media = media }
                    }
                }
            }
            if model.availableRoles.count > 2 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(model.availableRoles) { role in
                            FilterChip(title: role.rawValue, selected: model.role == role) { model.role = role }
                        }
                    }
                }
            }
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Filmografide ara", text: $model.query).textInputAutocapitalization(.never).autocorrectionDisabled()
                    .accessibilityIdentifier("filmographySearch")
                if !model.query.isEmpty { Button { model.query = "" } label: { Image(systemName: "xmark.circle.fill") }.accessibilityLabel("Filmografi aramasını temizle").frame(minWidth: 44, minHeight: 44) }
            }.padding(.horizontal, 14).frame(minHeight: 52).overlay(Rectangle().strokeBorder(CineTheme.border))
            HStack {
                Text("\(model.filtered.count) yapım").font(.cineLabel).foregroundStyle(.secondary)
                Spacer()
                Menu {
                    Picker("Sıralama", selection: $model.sort) { ForEach(FilmographySort.allCases) { Text($0.rawValue).tag($0) } }
                } label: { Label(model.sort.rawValue, systemImage: "arrow.up.arrow.down").font(.caption).frame(minHeight: 44) }
                    .accessibilityLabel("Filmografiyi sırala")
            }
            if model.filtered.isEmpty {
                StatusPanel(title: "Bu seçimde yapım yok", message: "Aramayı veya filtrelerini değiştirerek diğer katkıları görebilirsin.")
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 280 : 150), spacing: 16, alignment: .top)], spacing: 28) {
                    ForEach(model.filtered) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            MovieCard(movie: entry.movie)
                            Text(entry.contribution).font(.caption).foregroundStyle(.secondary).lineLimit(3)
                        }
                    }
                }
            }
        }
    }
    private func formattedDate(_ value: String) -> String {
        let input = DateFormatter(); input.locale = Locale(identifier: "en_US_POSIX"); input.dateFormat = "yyyy-MM-dd"
        guard let date = input.date(from: value) else { return value }
        return date.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "tr_TR")))
    }
}
