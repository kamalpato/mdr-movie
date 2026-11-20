import Foundation

struct GenreListResponseDTO: Decodable {
    let genres: [GenreDTO]
}

struct GenreDTO: Decodable {
    let id: Int
    let name: String

    func toDomain() -> Genre {
        Genre(id: id, name: name)
    }
}

struct PaginatedMoviesResponseDTO: Decodable {
    let page: Int
    let totalPages: Int
    let results: [MovieDTO]
}

struct MovieDTO: Decodable {
    let id: Int
    let originalTitle: String?
    let title: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let releaseDate: String?
    let genreIds: [Int]?
    let runtime: Int?
    let genres: [GenreDTO]?
    let tagline: String?
    let status: String?

    func toDomain() -> Movie {
        Movie(
            id: id,
            title: originalTitle ?? title ?? "Untitled",
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage ?? 0,
            genreNames: GenreCatalog.names(for: genreIds ?? [])
        )
    }

    func toDetailDomain() -> MovieDetail {
        let names: [String]
        if let genres, !genres.isEmpty {
            names = genres.map(\.name)
        } else {
            names = GenreCatalog.names(for: genreIds ?? [])
        }

        return MovieDetail(
            id: id,
            title: originalTitle ?? title ?? "Untitled",
            overview: overview ?? "",
            releaseDate: releaseDate,
            voteAverage: voteAverage ?? 0,
            voteCount: voteCount ?? 0,
            genreNames: names,
            posterPath: posterPath,
            backdropPath: backdropPath,
            runtimeMinutes: runtime,
            tagline: tagline,
            status: status
        )
    }
}

struct PaginatedReviewsResponseDTO: Decodable {
    let page: Int
    let totalPages: Int
    let results: [ReviewDTO]
}

struct ReviewDTO: Decodable {
    let id: String
    let author: String?
    let content: String?
    let createdAt: String?
    let authorDetails: AuthorDetailsDTO?

    func toDomain() -> MovieReview {
        MovieReview(
            id: id,
            author: author ?? authorDetails?.username ?? "Anonymous",
            content: content ?? "",
            rating: authorDetails?.rating,
            createdAt: createdAt
        )
    }
}

struct AuthorDetailsDTO: Decodable {
    let username: String?
    let rating: Double?
}

struct VideosResponseDTO: Decodable {
    let results: [VideoDTO]
}

struct VideoDTO: Decodable {
    let id: String
    let name: String?
    let key: String?
    let site: String?
    let type: String?

    func toTrailer() -> MovieTrailer? {
        guard let key,
              let site,
              site.lowercased() == "youtube",
              let type,
              ["Trailer", "Teaser"].contains(type)
        else { return nil }

        return MovieTrailer(
            id: id,
            name: name ?? type,
            key: key,
            site: site,
            type: type
        )
    }
}

struct CreditsDTO: Decodable {
    struct CastDTO: Decodable {
        let id: Int
        let name: String
        let character: String?
        let profilePath: String?
    }

    let cast: [CastDTO]?
}
