import XCTest
@testable import MandiriMovies

@MainActor
final class MoviesByGenrePresenterTests: XCTestCase {
    func testOnAppearLoadsFirstPage_positive() async {
        let interactor = MockMoviesByGenreInteractor()
        interactor.pages[1] = .success(
            PageResult(items: [TestFixtures.sampleMovie()], page: 1, totalPages: 3)
        )
        let presenter = MoviesByGenrePresenter(
            genre: TestFixtures.sampleGenre(),
            interactor: interactor,
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { !presenter.state.isLoading }

        XCTAssertEqual(presenter.state.movies.count, 1)
        XCTAssertEqual(presenter.state.currentPage, 1)
        XCTAssertTrue(presenter.state.hasMore)
        XCTAssertNil(presenter.state.errorMessage)
    }

    func testLoadNextPageAppends_positive() async {
        let interactor = MockMoviesByGenreInteractor()
        interactor.pages[1] = .success(
            PageResult(items: [TestFixtures.sampleMovie(id: 1)], page: 1, totalPages: 2)
        )
        interactor.pages[2] = .success(
            PageResult(items: [TestFixtures.sampleMovie(id: 2, title: "Next")], page: 2, totalPages: 2)
        )
        let presenter = MoviesByGenrePresenter(
            genre: TestFixtures.sampleGenre(),
            interactor: interactor,
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { presenter.state.hasContent }

        presenter.loadNextPageIfNeeded()
        await waitUntil { !presenter.state.isLoadingMore }

        XCTAssertEqual(presenter.state.movies.count, 2)
        XCTAssertEqual(presenter.state.currentPage, 2)
        XCTAssertFalse(presenter.state.hasMore)
        XCTAssertEqual(interactor.requestedPages, [1, 2])
    }

    func testOnAppearFailure_negative() async {
        let interactor = MockMoviesByGenreInteractor()
        interactor.pages[1] = .failure(APIError.server(statusCode: 503))
        let presenter = MoviesByGenrePresenter(
            genre: TestFixtures.sampleGenre(),
            interactor: interactor,
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { !presenter.state.isLoading }

        XCTAssertTrue(presenter.state.movies.isEmpty)
        XCTAssertEqual(
            presenter.state.errorMessage,
            APIError.server(statusCode: 503).localizedDescription
        )
    }

    func testLoadMoreFailureKeepsExisting_negative() async {
        let interactor = MockMoviesByGenreInteractor()
        interactor.pages[1] = .success(
            PageResult(items: [TestFixtures.sampleMovie()], page: 1, totalPages: 2)
        )
        interactor.pages[2] = .failure(APIError.underlying(message: "network"))
        let presenter = MoviesByGenrePresenter(
            genre: TestFixtures.sampleGenre(),
            interactor: interactor,
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { presenter.state.hasContent }

        presenter.loadNextPageIfNeeded()
        await waitUntil { !presenter.state.isLoadingMore }

        XCTAssertEqual(presenter.state.movies.count, 1)
        XCTAssertEqual(presenter.state.loadMoreErrorMessage, "network")
    }
}
