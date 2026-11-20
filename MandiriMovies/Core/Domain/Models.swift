import Foundation

struct Genre: Identifiable, Hashable, EntityInterface {
    let id: Int
    let name: String
}

struct Movie: Identifiable, Hashable, EntityInterface {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let genreNames: [String]

    var posterURL: URL? {
        guard let posterPath, !posterPath.isEmpty else { return nil }
        return URL(string: AppConfig.posterImageBase + posterPath)
    }

    var backdropURL: URL? {
        guard let backdropPath, !backdropPath.isEmpty else { return nil }
        return URL(string: AppConfig.backdropImageBase + backdropPath)
    }
}

struct MovieDetail: Identifiable, Hashable, EntityInterface {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let genreNames: [String]
    let posterPath: String?
    let backdropPath: String?
    let runtimeMinutes: Int?
    let tagline: String?
    let status: String?

    var posterURL: URL? {
        guard let posterPath, !posterPath.isEmpty else { return nil }
        return URL(string: AppConfig.posterImageBase + posterPath)
    }

    var backdropURL: URL? {
        guard let backdropPath, !backdropPath.isEmpty else { return nil }
        return URL(string: AppConfig.backdropImageBase + backdropPath)
    }
}

struct MovieReview: Identifiable, Hashable, EntityInterface {
    let id: String
    let author: String
    let content: String
    let rating: Double?
    let createdAt: String?
}

struct MovieTrailer: Hashable, EntityInterface {
    let id: String
    let name: String
    let key: String
    let site: String
    let type: String

    var youtubeURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    var embedURL: URL? {
        URL(string: "https://www.youtube.com/embed/\(key)?playsinline=1")
    }
}

struct Actor: Identifiable, Hashable, EntityInterface {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?

    var profileURL: URL? {
        guard let profilePath, !profilePath.isEmpty else { return nil }
        return URL(string: AppConfig.posterImageBase + profilePath)
    }
}

struct PageResult<T> {
    let items: [T]
    let page: Int
    let totalPages: Int

    var hasMore: Bool { page < totalPages }
}

enum GenreCatalog {
    static let namesByID: [Int: String] = [
        12: "Adventure", 14: "Fantasy", 16: "Animation", 18: "Drama",
        27: "Horror", 28: "Action", 35: "Comedy", 36: "History",
        37: "Western", 53: "Thriller", 80: "Crime", 99: "Documentary",
        878: "Science Fiction", 9648: "Mystery", 10402: "Music",
        10749: "Romance", 10751: "Family", 10752: "War", 10770: "TV Movie"
    ]

    static func names(for ids: [Int]) -> [String] {
        ids.compactMap { namesByID[$0] }
    }
}

enum RatingMath {
    static func filledStarCount(for rating: Double, maxStars: Int = 5) -> Int {
        let filled = Int(floor(rating / 2.0))
        return min(max(filled, 0), maxStars)
    }
}
