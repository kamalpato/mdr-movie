import Foundation
@testable import MandiriMovies

final class MockHTTPSession: HTTPSession {
    var result: Result<(Data, URLResponse), Error>
    private(set) var lastRequest: URLRequest?

    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

enum TestFixtures {
    static func httpResponse(
        url: URL = URL(string: "https://api.themoviedb.org/3/discover/movie")!,
        statusCode: Int = 200
    ) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    static let genresJSON = """
    {
      "genres": [
        {"id": 28, "name": "Action"},
        {"id": 18, "name": "Drama"}
      ]
    }
    """.data(using: .utf8)!

    static let discoverJSON = """
    {
      "page": 1,
      "total_pages": 3,
      "results": [
        {
          "id": 1,
          "original_title": "Inception",
          "overview": "Dreams within dreams.",
          "poster_path": "/poster.jpg",
          "backdrop_path": "/backdrop.jpg",
          "vote_average": 8.8,
          "vote_count": 1000,
          "release_date": "2010-07-16",
          "genre_ids": [28, 878]
        }
      ]
    }
    """.data(using: .utf8)!

    static let discoverPage2JSON = """
    {
      "page": 2,
      "total_pages": 3,
      "results": [
        {
          "id": 2,
          "original_title": "Interstellar",
          "overview": "Space.",
          "poster_path": "/p2.jpg",
          "backdrop_path": "/b2.jpg",
          "vote_average": 8.6,
          "release_date": "2014-11-07",
          "genre_ids": [878]
        }
      ]
    }
    """.data(using: .utf8)!

    static let movieDetailJSON = """
    {
      "id": 1,
      "original_title": "Inception",
      "overview": "Dreams within dreams.",
      "poster_path": "/poster.jpg",
      "backdrop_path": "/backdrop.jpg",
      "vote_average": 8.8,
      "vote_count": 22000,
      "release_date": "2010-07-16",
      "runtime": 148,
      "tagline": "Your mind is the scene of the crime.",
      "status": "Released",
      "genres": [{"id": 28, "name": "Action"}]
    }
    """.data(using: .utf8)!

    static let reviewsJSON = """
    {
      "page": 1,
      "total_pages": 2,
      "results": [
        {
          "id": "r1",
          "author": "Alice",
          "content": "Amazing movie.",
          "created_at": "2020-01-01",
          "author_details": {"username": "alice", "rating": 9.0}
        }
      ]
    }
    """.data(using: .utf8)!

    static let reviewsPage2JSON = """
    {
      "page": 2,
      "total_pages": 2,
      "results": [
        {
          "id": "r2",
          "author": "Bob",
          "content": "Mind bending.",
          "created_at": "2020-02-01",
          "author_details": {"username": "bob", "rating": 8.0}
        }
      ]
    }
    """.data(using: .utf8)!

    static let videosJSON = """
    {
      "results": [
        {
          "id": "v1",
          "name": "Official Trailer",
          "key": "YoHD9XEInc0",
          "site": "YouTube",
          "type": "Trailer"
        }
      ]
    }
    """.data(using: .utf8)!

    static let emptyVideosJSON = """
    {"results": []}
    """.data(using: .utf8)!

    static let invalidJSON = "{ not-json }".data(using: .utf8)!

    static func sampleMovie(
        id: Int = 1,
        title: String = "Inception",
        rating: Double = 8.8
    ) -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "Overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2010-07-16",
            voteAverage: rating,
            genreNames: ["Action", "Science Fiction"]
        )
    }

    static func sampleGenre(id: Int = 28, name: String = "Action") -> Genre {
        Genre(id: id, name: name)
    }

    static func sampleReview(id: String = "r1", author: String = "Alice") -> MovieReview {
        MovieReview(
            id: id,
            author: author,
            content: "Great",
            rating: 9,
            createdAt: "2020-01-01"
        )
    }
}
