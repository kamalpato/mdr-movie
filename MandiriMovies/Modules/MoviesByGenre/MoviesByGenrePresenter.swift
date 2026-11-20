import Foundation

protocol MoviesByGenrePresenterInterface: PresenterInterface {
    var state: MoviesByGenreViewState { get }
    func onAppear()
    func retry()
    func loadNextPageIfNeeded()
    func didSelectMovie(_ movie: Movie)
}

@MainActor
final class MoviesByGenrePresenter: MoviesByGenrePresenterInterface {
    @Published private(set) var state: MoviesByGenreViewState

    private let interactor: MoviesByGenreInteractorInterface
    private weak var router: AppRouter?
    private var loadTask: Task<Void, Never>?

    init(
        genre: Genre,
        interactor: MoviesByGenreInteractorInterface,
        router: AppRouter
    ) {
        self.interactor = interactor
        self.router = router
        self.state = MoviesByGenreViewState(genre: genre)
    }

    func onAppear() {
        guard !state.hasContent, !state.isLoading else { return }
        load(page: 1, append: false)
    }

    func retry() {
        load(page: 1, append: false)
    }

    func loadNextPageIfNeeded() {
        guard state.hasMore, !state.isLoading, !state.isLoadingMore else { return }
        load(page: state.currentPage + 1, append: true)
    }

    func didSelectMovie(_ movie: Movie) {
        router?.navigate(to: .movieDetail(movie))
    }

    private func load(page: Int, append: Bool) {
        loadTask?.cancel()

        if append {
            state.isLoadingMore = true
            state.loadMoreErrorMessage = nil
        } else {
            state.isLoading = true
            state.errorMessage = nil
            state.loadMoreErrorMessage = nil
        }

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await interactor.fetchMovies(
                    genreID: state.genre.id,
                    page: page
                )
                guard !Task.isCancelled else { return }

                if append {
                    let existingIDs = Set(state.movies.map(\.id))
                    let newItems = result.items.filter { !existingIDs.contains($0.id) }
                    state.movies.append(contentsOf: newItems)
                } else {
                    state.movies = result.items
                }
                state.currentPage = result.page
                state.totalPages = result.totalPages
                state.isLoading = false
                state.isLoadingMore = false
            } catch {
                guard !Task.isCancelled else { return }
                if append {
                    state.loadMoreErrorMessage = error.localizedDescription
                    state.isLoadingMore = false
                } else {
                    state.errorMessage = error.localizedDescription
                    state.isLoading = false
                }
            }
        }
    }
}
