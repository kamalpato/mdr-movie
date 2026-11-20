import XCTest
@testable import MandiriMovies

@MainActor
final class MovieDetailPresenterTests: XCTestCase {
    func testOnAppearLoadsDetailTrailerReviews_positive() async {
        let detail = MovieDetail(
            id: 1,
            title: "Inception",
            overview: "Overview",
            releaseDate: "2010-07-16",
            voteAverage: 8.8,
            voteCount: 100,
            genreNames: ["Action"],
            posterPath: "/p.jpg",
            backdropPath: "/b.jpg",
            runtimeMinutes: 148,
            tagline: "Tag",
            status: "Released"
        )
        let trailer = MovieTrailer(
            id: "v1",
            name: "Trailer",
            key: "YoHD9XEInc0",
            site: "YouTube",
            type: "Trailer"
        )
        let interactor = MockMovieDetailInteractor(
            detailResult: .success(detail),
            trailerResult: .success(trailer),
            castResult: .success([
                Actor(id: 10, name: "Leonardo DiCaprio", character: "Cobb", profilePath: nil)
            ]),
            reviewPages: [
                1: .success(
                    PageResult(
                        items: [TestFixtures.sampleReview()],
                        page: 1,
                        totalPages: 2
                    )
                )
            ]
        )
        let presenter = MovieDetailPresenter(
            movie: TestFixtures.sampleMovie(),
            interactor: interactor,
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil {
            presenter.state.detail != nil
                && presenter.state.trailer != nil
                && !presenter.state.cast.isEmpty
                && !presenter.state.reviews.isEmpty
                && !presenter.state.isLoading
        }

        XCTAssertEqual(presenter.state.detail?.title, "Inception")
        XCTAssertEqual(presenter.state.trailer?.key, "YoHD9XEInc0")
        XCTAssertEqual(presenter.state.cast.first?.name, "Leonardo DiCaprio")
        XCTAssertEqual(interactor.requestedCastMovieIds, [1])
        XCTAssertEqual(presenter.state.reviews.first?.author, "Alice")
        XCTAssertTrue(presenter.state.hasMoreReviews)
        XCTAssertNil(presenter.state.errorMessage)
    }

    func testLoadMoreReviews_positive() async {
        let interactor = MockMovieDetailInteractor(
            detailResult: .success(
                MovieDetail(
                    id: 1, title: "Inception", overview: "", releaseDate: nil,
                    voteAverage: 8, voteCount: 1, genreNames: [], posterPath: nil,
                    backdropPath: nil, runtimeMinutes: nil, tagline: nil, status: nil
                )
            ),
            trailerResult: .success(nil),
            reviewPages: [
                1: .success(PageResult(items: [TestFixtures.sampleReview(id: "r1")], page: 1, totalPages: 2)),
                2: .success(PageResult(items: [TestFixtures.sampleReview(id: "r2", author: "Bob")], page: 2, totalPages: 2))
            ]
        )
        let presenter = MovieDetailPresenter(
            movie: TestFixtures.sampleMovie(),
            interactor: interactor,
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { presenter.state.reviews.count == 1 }

        presenter.loadMoreReviewsIfNeeded()
        await waitUntil { !presenter.state.isLoadingMoreReviews && presenter.state.reviews.count == 2 }

        XCTAssertEqual(presenter.state.reviews.map(\.author), ["Alice", "Bob"])
        XCTAssertFalse(presenter.state.hasMoreReviews)
    }

    func testDetailFailureKeepsSeedMovie_negative() async {
        let interactor = MockMovieDetailInteractor(
            detailResult: .failure(APIError.server(statusCode: 404)),
            trailerResult: .failure(APIError.server(statusCode: 404)),
            reviewPages: [
                1: .failure(APIError.server(statusCode: 404))
            ]
        )
        let presenter = MovieDetailPresenter(
            movie: TestFixtures.sampleMovie(title: "Seed"),
            interactor: interactor,
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { !presenter.state.isLoading }

        XCTAssertEqual(presenter.state.displayTitle, "Seed")
        XCTAssertNil(presenter.state.detail)
        XCTAssertNotNil(presenter.state.trailerErrorMessage)
        XCTAssertNotNil(presenter.state.reviewsErrorMessage)
    }

    func testNoTrailerMessage_negative() async {
        let interactor = MockMovieDetailInteractor(
            detailResult: .success(
                MovieDetail(
                    id: 1, title: "Inception", overview: "", releaseDate: nil,
                    voteAverage: 8, voteCount: 1, genreNames: [], posterPath: nil,
                    backdropPath: nil, runtimeMinutes: nil, tagline: nil, status: nil
                )
            ),
            trailerResult: .success(nil),
            reviewPages: [
                1: .success(PageResult(items: [], page: 1, totalPages: 1))
            ]
        )
        let presenter = MovieDetailPresenter(
            movie: TestFixtures.sampleMovie(),
            interactor: interactor,
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { !presenter.state.isLoading && presenter.state.reviewsErrorMessage != nil }

        XCTAssertEqual(presenter.state.trailerErrorMessage, "No YouTube trailer available.")
        XCTAssertEqual(presenter.state.reviewsErrorMessage, "No reviews yet.")
    }
}
