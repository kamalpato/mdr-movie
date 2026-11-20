import XCTest
@testable import MandiriMovies

@MainActor
final class GenresPresenterTests: XCTestCase {
    func testOnAppearLoadsGenres_positive() async {
        let presenter = GenresPresenter(
            interactor: MockGenresInteractor(
                result: .success([TestFixtures.sampleGenre()])
            ),
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { !presenter.state.isLoading }

        XCTAssertEqual(presenter.state.genres.count, 1)
        XCTAssertEqual(presenter.state.genres.first?.name, "Action")
        XCTAssertNil(presenter.state.errorMessage)
    }

    func testOnAppearFailure_negative() async {
        let presenter = GenresPresenter(
            interactor: MockGenresInteractor(result: .failure(APIError.server(statusCode: 500))),
            router: AppRouter()
        )

        presenter.onAppear()
        await waitUntil { !presenter.state.isLoading }

        XCTAssertTrue(presenter.state.genres.isEmpty)
        XCTAssertEqual(
            presenter.state.errorMessage,
            APIError.server(statusCode: 500).localizedDescription
        )
    }

    func testDidSelectGenreNavigates_positive() {
        let router = AppRouter()
        let presenter = GenresPresenter(
            interactor: MockGenresInteractor(result: .success([])),
            router: router
        )

        presenter.didSelectGenre(TestFixtures.sampleGenre())
        XCTAssertEqual(router.path.count, 1)
    }
}
