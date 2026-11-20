import XCTest
@testable import MandiriMovies

final class DomainMappingTests: XCTestCase {
    func testGenreCatalogMapsKnownIDs_positive() {
        XCTAssertEqual(GenreCatalog.names(for: [28, 878]), ["Action", "Science Fiction"])
    }

    func testGenreCatalogDropsUnknownIDs_negative() {
        XCTAssertEqual(GenreCatalog.names(for: [999_999, 28]), ["Action"])
    }

    func testRatingMathFilledStars_positive() {
        XCTAssertEqual(RatingMath.filledStarCount(for: 8.8), 4)
        XCTAssertEqual(RatingMath.filledStarCount(for: 10), 5)
    }

    func testRatingMathClampsOutOfRange_negative() {
        XCTAssertEqual(RatingMath.filledStarCount(for: -2), 0)
        XCTAssertEqual(RatingMath.filledStarCount(for: 100), 5)
    }

    func testMovieDTOToDomain_positive() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(
            PaginatedMoviesResponseDTO.self,
            from: TestFixtures.discoverJSON
        ).results[0]

        let movie = dto.toDomain()
        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.title, "Inception")
        XCTAssertNotNil(movie.posterURL)
        XCTAssertNotNil(movie.backdropURL)
    }

    func testVideoDTOFiltersNonYouTube_negative() throws {
        let json = """
        {"id":"1","name":"Clip","key":"abc","site":"Vimeo","type":"Trailer"}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(VideoDTO.self, from: json)
        XCTAssertNil(dto.toTrailer())
    }

    func testMovieDetailDTOFallbackTitle_negative() throws {
        let json = #"{"id":7,"overview":"","vote_average":0}"#.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(MovieDTO.self, from: json)
        XCTAssertEqual(dto.toDetailDomain().title, "Untitled")
    }
}
