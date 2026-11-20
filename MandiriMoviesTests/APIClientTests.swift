import XCTest
@testable import MandiriMovies

final class APIClientTests: XCTestCase {
    func testRequestDecodesDiscoverMovies_positive() async throws {
        let session = MockHTTPSession(
            result: .success((TestFixtures.discoverJSON, TestFixtures.httpResponse()))
        )
        let client = APIClient(session: session, apiKeyProvider: { "test-key" })

        let response: PaginatedMoviesResponseDTO = try await client.request(
            TMDBEndpoint.discoverMovies(genreID: 28, page: 1)
        )

        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 3)
        XCTAssertEqual(response.results.first?.toDomain().title, "Inception")
        XCTAssertTrue(session.lastRequest?.url?.absoluteString.contains("api_key=test-key") == true)
        XCTAssertTrue(session.lastRequest?.url?.absoluteString.contains("with_genres=28") == true)
    }

    func testRequestMissingAPIKey_negative() async {
        let client = APIClient(
            session: MockHTTPSession(result: .success((Data(), TestFixtures.httpResponse()))),
            apiKeyProvider: { "" }
        )

        do {
            let _: PaginatedMoviesResponseDTO = try await client.request(TMDBEndpoint.discoverMovies())
            XCTFail("Expected missingAPIKey error")
        } catch let error as APIError {
            XCTAssertEqual(error, .missingAPIKey)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testRequestServerError_negative() async {
        let session = MockHTTPSession(
            result: .success((Data(), TestFixtures.httpResponse(statusCode: 401)))
        )
        let client = APIClient(session: session, apiKeyProvider: { "test-key" })

        do {
            let _: PaginatedMoviesResponseDTO = try await client.request(TMDBEndpoint.discoverMovies())
            XCTFail("Expected server error")
        } catch let error as APIError {
            XCTAssertEqual(error, .server(statusCode: 401))
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testRequestDecodingFailure_negative() async {
        let session = MockHTTPSession(
            result: .success((TestFixtures.invalidJSON, TestFixtures.httpResponse()))
        )
        let client = APIClient(session: session, apiKeyProvider: { "test-key" })

        do {
            let _: PaginatedMoviesResponseDTO = try await client.request(TMDBEndpoint.discoverMovies())
            XCTFail("Expected decodingFailed")
        } catch let error as APIError {
            XCTAssertEqual(error, .decodingFailed)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
