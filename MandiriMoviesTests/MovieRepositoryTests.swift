import XCTest
@testable import MandiriMovies

final class MovieRepositoryTests: XCTestCase {
    func testFetchGenres_positive() async throws {
        let session = MockHTTPSession(
            result: .success((TestFixtures.genresJSON, TestFixtures.httpResponse()))
        )
        let repository = MovieRepository(
            apiClient: APIClient(session: session, apiKeyProvider: { "test-key" })
        )

        let genres = try await repository.fetchGenres()
        XCTAssertEqual(genres.map(\.name), ["Action", "Drama"])
    }

    func testFetchDiscoverMovies_positive() async throws {
        let session = MockHTTPSession(
            result: .success((TestFixtures.discoverJSON, TestFixtures.httpResponse()))
        )
        let repository = MovieRepository(
            apiClient: APIClient(session: session, apiKeyProvider: { "test-key" })
        )

        let page = try await repository.fetchDiscoverMovies(genreID: 28, page: 1)
        XCTAssertEqual(page.items.count, 1)
        XCTAssertEqual(page.page, 1)
        XCTAssertTrue(page.hasMore)
    }

    func testFetchMovieDetail_positive() async throws {
        let session = MockHTTPSession(
            result: .success((TestFixtures.movieDetailJSON, TestFixtures.httpResponse()))
        )
        let repository = MovieRepository(
            apiClient: APIClient(session: session, apiKeyProvider: { "test-key" })
        )

        let detail = try await repository.fetchMovieDetail(id: 1)
        XCTAssertEqual(detail.title, "Inception")
        XCTAssertEqual(detail.runtimeMinutes, 148)
        XCTAssertEqual(detail.voteCount, 22000)
    }

    func testFetchReviews_positive() async throws {
        let session = MockHTTPSession(
            result: .success((TestFixtures.reviewsJSON, TestFixtures.httpResponse()))
        )
        let repository = MovieRepository(
            apiClient: APIClient(session: session, apiKeyProvider: { "test-key" })
        )

        let page = try await repository.fetchMovieReviews(id: 1, page: 1)
        XCTAssertEqual(page.items.first?.author, "Alice")
        XCTAssertTrue(page.hasMore)
    }

    func testFetchTrailer_positive() async throws {
        let session = MockHTTPSession(
            result: .success((TestFixtures.videosJSON, TestFixtures.httpResponse()))
        )
        let repository = MovieRepository(
            apiClient: APIClient(session: session, apiKeyProvider: { "test-key" })
        )

        let trailer = try await repository.fetchMovieTrailer(id: 1)
        XCTAssertEqual(trailer?.key, "YoHD9XEInc0")
        XCTAssertEqual(trailer?.site, "YouTube")
    }

    func testFetchTrailerEmpty_negative() async throws {
        let session = MockHTTPSession(
            result: .success((TestFixtures.emptyVideosJSON, TestFixtures.httpResponse()))
        )
        let repository = MovieRepository(
            apiClient: APIClient(session: session, apiKeyProvider: { "test-key" })
        )

        let trailer = try await repository.fetchMovieTrailer(id: 1)
        XCTAssertNil(trailer)
    }

    func testFetchGenresEmpty_negative() async {
        let empty = #"{"genres":[]}"#.data(using: .utf8)!
        let session = MockHTTPSession(result: .success((empty, TestFixtures.httpResponse())))
        let repository = MovieRepository(
            apiClient: APIClient(session: session, apiKeyProvider: { "test-key" })
        )

        do {
            _ = try await repository.fetchGenres()
            XCTFail("Expected emptyData")
        } catch let error as APIError {
            XCTAssertEqual(error, .emptyData)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
