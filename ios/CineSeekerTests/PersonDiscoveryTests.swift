import XCTest
@testable import CineSeeker

final class PersonDiscoveryTests: XCTestCase {
    func testFilmographyMergesContributionsWithoutMixingMovieAndTVIdentifiers() throws {
        let credits = try profile().combinedCredits!
        let entries = FilmographyEntry.merged(credits)
        XCTAssertEqual(entries.count, 4)
        let film = try XCTUnwrap(entries.first { $0.id == "movie:1" })
        XCTAssertEqual(film.roles, [.acting, .directing, .writing])
        XCTAssertEqual(film.characters, ["Ali"])
        XCTAssertEqual(entries.first { $0.id == "tv:1" }?.movie.displayTitle, "Dizi")
        XCTAssertFalse(entries.contains { $0.movie.id == 99 })
    }
    @MainActor func testFilmographyFiltersAndChronologicalSorting() async throws {
        let model = PersonViewModel(repository: PortraitSource(value: try profile()))
        await model.load(id: 7)
        XCTAssertEqual(model.filtered.first?.id, "movie:1")
        model.media = .movie; model.role = .directing; model.query = "isik"
        XCTAssertEqual(model.filtered.map(\.id), ["movie:1"])
        model.query = ""; model.role = .all; model.sort = .oldest
        XCTAssertEqual(model.filtered.map(\.id), ["movie:2", "movie:1", "movie:3"])
        model.sort = .newest
        XCTAssertEqual(model.filtered.map(\.id), ["movie:1", "movie:2", "movie:3"])
    }
    @MainActor func testMissingTurkishBiographyUsesEnglishWithoutReplacingFilmography() async throws {
        let source = PortraitSource(value: try profile(biography: ""))
        let model = PersonViewModel(repository: source)
        await model.load(id: 7)
        XCTAssertEqual(model.biography, "English biography")
        XCTAssertTrue(model.biographyIsEnglish)
        XCTAssertEqual(model.entries.count, 4)
        let languages = await source.languages
        XCTAssertEqual(languages, ["tr-TR", "en-US"])
    }
    @MainActor func testOptionalBiographyFailureKeepsFilmography() async throws {
        let model = PersonViewModel(repository: PortraitSource(value: try profile(biography: ""), failFallback: true))
        await model.load(id: 7)
        XCTAssertNil(model.error)
        XCTAssertNil(model.biography)
        XCTAssertEqual(model.entries.count, 4)
        XCTAssertFalse(model.loading)
    }
    @MainActor func testFailedRefreshPreservesLoadedPortrait() async throws {
        let source = PortraitSource(value: try profile())
        let model = PersonViewModel(repository: source)
        await model.load(id: 7)
        await source.setFailure()
        await model.load(id: 7)
        XCTAssertEqual(model.entries.count, 4)
        XCTAssertNotNil(model.error)
        XCTAssertFalse(model.loading)
    }
    func testExplicitLanguageOverridesTurkishDefault() throws {
        let defaultRequest = try NetworkManager.makeRequest(.init(path: "person/7"), token: "test")
        let englishRequest = try NetworkManager.makeRequest(.init(path: "person/7", query: ["language": "en-US"]), token: "test")
        XCTAssertTrue(defaultRequest.url!.absoluteString.contains("language=tr-TR"))
        XCTAssertTrue(englishRequest.url!.absoluteString.contains("language=en-US"))
    }
    @MainActor func testTrailerSafetyPriorityAndRelatedTitleDeduplication() throws {
        let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
        let detail = try decoder.decode(MovieDetail.self, from: Data(#"{"id":1,"genres":[],"videos":{"results":[{"key":"english","site":"YouTube","type":"Trailer","official":true,"iso_639_1":"en"},{"key":"turkish","site":"YouTube","type":"Trailer","official":true,"iso_639_1":"tr"},{"key":"bad/key","site":"YouTube","type":"Trailer","official":true,"iso_639_1":"tr"}]},"recommendations":{"page":1,"total_pages":1,"results":[{"id":1,"name":"Kaynak"},{"id":2,"name":"Dizi"},{"id":2,"name":"Tekrar"}]}}"#.utf8))
        let model = MovieDetailViewModel(); model.detail = detail
        XCTAssertEqual(model.trailer?.key, "turkish")
        XCTAssertEqual(model.trailer?.url?.host, "www.youtube.com")
        XCTAssertNil(detail.videos?.results.last?.url)
        XCTAssertEqual(model.related(to: Movie(id: 1, name: "Kaynak", mediaType: .tv)).map(\.key), ["tv:2"])
    }
    private func profile(biography: String = "Türkçe biyografi") throws -> PersonProfile {
        let json = #"{"id":7,"name":"Örnek kişi","biography":"BIO","combined_credits":{"cast":[{"id":1,"title":"Işık","media_type":"movie","character":"Ali","release_date":"2024-01-01","popularity":10},{"id":1,"title":"Işık","media_type":"movie","character":"Ali"},{"id":1,"name":"Dizi","media_type":"tv","first_air_date":"2023-01-01"},{"id":2,"title":"Eski","media_type":"movie","release_date":"2000-01-01"},{"id":3,"title":"Tarihsiz","media_type":"movie"},{"id":99,"title":"Yetişkin","media_type":"movie","adult":true}],"crew":[{"id":1,"title":"Işık","media_type":"movie","job":"Director","department":"Directing"},{"id":1,"title":"Işık","media_type":"movie","job":"Screenplay","department":"Writing"}]}}"#.replacingOccurrences(of: "BIO", with: biography)
        let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(PersonProfile.self, from: Data(json.utf8))
    }
}
private actor PortraitSource: PersonRepository {
    let value: PersonProfile
    let failFallback: Bool
    var fails = false
    var languages: [String] = []
    init(value: PersonProfile, failFallback: Bool = false) { self.value = value; self.failFallback = failFallback }
    func setFailure() { fails = true }
    func person(id: Int, language: String, includingCredits: Bool) async throws -> PersonProfile {
        languages.append(language)
        if fails || (language == "en-US" && failFallback) { throw URLError(.notConnectedToInternet) }
        if language == "en-US" {
            return PersonProfile(id: id, name: value.name, biography: "English biography", birthday: nil, deathday: nil, placeOfBirth: nil, knownForDepartment: nil, profilePath: nil, combinedCredits: nil)
        }
        return value
    }
}
