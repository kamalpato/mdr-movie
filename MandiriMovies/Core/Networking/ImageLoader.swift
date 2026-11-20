import Foundation
import UIKit

enum ImageMemoryCache {
    static let shared: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 120
        cache.totalCostLimit = 64 * 1024 * 1024
        return cache
    }()
}

enum ImageURLCacheConfigurator {
    static func configure() {
        URLCache.shared = URLCache(
            memoryCapacity: 64 * 1024 * 1024,
            diskCapacity: 256 * 1024 * 1024,
            directory: nil
        )
    }
}

@MainActor
final class ImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?

    private var task: Task<Void, Never>?
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    func load() {
        guard let url else {
            image = nil
            return
        }

        if let cached = ImageMemoryCache.shared.object(forKey: url as NSURL) {
            image = cached
            return
        }

        task?.cancel()
        task = Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return }
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    return
                }
                guard let uiImage = UIImage(data: data) else { return }
                ImageMemoryCache.shared.setObject(
                    uiImage,
                    forKey: url as NSURL,
                    cost: data.count
                )
                image = uiImage
            } catch {
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
