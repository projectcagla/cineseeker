import SwiftUI
import UIKit
import ImageIO

actor ImageCache {
    static let shared = ImageCache()
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 16_000_000, diskCapacity: 200_000_000, diskPath: "posters")
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 20
        return URLSession(configuration: config)
    }()
    private var memory: [URL: Data] = [:]
    private var order: [URL] = []
    private var byteCount = 0
    private var pending: [URL: Task<Data, Error>] = [:]
    private let limit = 24_000_000

    func load(_ url: URL) async throws -> Data {
        if let data = memory[url] {
            order.removeAll { $0 == url }; order.append(url)
            return data
        }
        if let task = pending[url] { return try await task.value }
        let task = Task { [session] in
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  http.mimeType?.hasPrefix("image/") == true, data.count <= 12_000_000 else { throw NetworkError.invalidResponse }
            return data
        }
        pending[url] = task
        defer { pending[url] = nil }
        let data = try await task.value
        while byteCount + data.count > limit, let oldest = order.first {
            order.removeFirst(); byteCount -= memory.removeValue(forKey: oldest)?.count ?? 0
        }
        memory[url] = data; order.append(url); byteCount += data.count
        return data
    }

    func thumbnail(_ url: URL, maxPixels: Int) async throws -> CGImage {
        let data = try await load(url)
        try Task.checkCancellation()
        guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixels
              ] as CFDictionary) else { throw NetworkError.invalidResponse }
        return image
    }
}

struct PosterImage: View {
    let path: String?
    var size = "w500"
    @State private var image: UIImage?
    private var requestID: String { "\(size):\(path ?? "")" }
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image { Image(uiImage: image).resizable().scaledToFill() }
                else {
                    Rectangle().fill(CineTheme.surface)
                        .overlay { Image(systemName: "film").font(.title2).foregroundStyle(.tertiary) }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }
        .accessibilityHidden(true)
        .task(id: requestID) {
            image = nil
            guard let path, path.hasPrefix("/"), !path.contains(".."),
                  let url = URL(string: "https://image.tmdb.org/t/p/\(size)\(path)") else { return }
            do {
                let width = Int(size.dropFirst()) ?? 500
                let thumbnail = try await ImageCache.shared.thumbnail(url, maxPixels: min(1200, width * 3 / 2))
                try Task.checkCancellation()
                image = UIImage(cgImage: thumbnail)
            } catch { /* Offline and missing artwork retain the neutral placeholder. */ }
        }
    }
}
