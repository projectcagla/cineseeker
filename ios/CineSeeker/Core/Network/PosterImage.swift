import SwiftUI
import UIKit
actor ImageCache {
    static let shared = ImageCache()
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 32_000_000, diskCapacity: 200_000_000, diskPath: "posters")
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
    private var memory: [URL: Data] = [:]
    func load(_ url: URL) async throws -> Data {
        if let data = memory[url] { return data }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw NetworkError.invalidResponse }
        if memory.count > 80 { memory.removeAll(keepingCapacity: true) }
        memory[url] = data
        return data
    }
}
struct PosterImage: View {
    let path: String?
    var size = "w500"
    @State private var image: UIImage?
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image { Image(uiImage: image).resizable().scaledToFill() }
                else { Rectangle().fill(CineTheme.surface).overlay { Image(systemName: "film").font(.title).foregroundStyle(.quaternary) } }
            }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }
        .accessibilityHidden(true)
        .task(id: path) {
            image = nil
            guard let path, path.hasPrefix("/"), let url = URL(string: "https://image.tmdb.org/t/p/\(size)\(path)") else { return }
            do { let data = try await ImageCache.shared.load(url); try Task.checkCancellation(); image = UIImage(data: data) }
            catch { /* Keep the accessible text and neutral artwork when an image is unavailable. */ }
        }
    }
}
