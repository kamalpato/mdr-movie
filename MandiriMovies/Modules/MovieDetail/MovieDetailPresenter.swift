import Foundation

protocol MovieDetailPresenterInterface: PresenterInterface {
    var state: MovieDetailViewState { get }
    func onAppear()
    func retry()
    func loadMoreReviewsIfNeeded()
    func didTapBack()
}

@MainActor
final class MovieDetailPresenter: MovieDetailPresenterInterface {
    @Published private(set) var state: MovieDetailViewState

    private let movieId: Int
    private let interactor: MovieDetailInteractorInterface
    private weak var router: AppRouter?
    private var loadTask: Task<Void, Never>?
    private var reviewsTask: Task<Void, Never>?

    init(
        movie: Movie,
        interactor: MovieDetailInteractorInterface,
        router: AppRouter
    ) {
        self.movieId = movie.id
        self.interactor = interactor
        self.router = router
        self.state = MovieDetailViewState(movie: movie)
    }

    func onAppear() {
        guard state.detail == nil, !state.isLoading else { return }
        loadAll()
    }

    func retry() {
        loadAll()
    }

    func loadMoreReviewsIfNeeded() {
        guard state.hasMoreReviews, !state.isLoadingMoreReviews, !state.isLoading else { return }
        loadReviews(page: state.reviewsPage + 1, append: true)
    }

    func didTapBack() {
        router?.pop()
    }

    private func loadAll() {
        loadTask?.cancel()
        reviewsTask?.cancel()

        state.isLoading = true
        state.errorMessage = nil
        state.trailerErrorMessage = nil
        state.castErrorMessage = nil
        state.reviewsErrorMessage = nil

        loadTask = Task { [weak self] in
            guard let self else { return }

            async let detailResult = interactor.fetchMovieDetail(id: movieId)
            async let trailerResult = interactor.fetchTrailer(id: movieId)
            async let castResult = interactor.fetchCast(id: movieId)

            do {
                let detail = try await detailResult
                guard !Task.isCancelled else { return }
                state.detail = detail
            } catch {
                guard !Task.isCancelled else { return }
                if state.movie == nil {
                    state.errorMessage = error.localizedDescription
                }
            }

            do {
                let trailer = try await trailerResult
                guard !Task.isCancelled else { return }
                state.trailer = trailer
                if trailer == nil {
                    state.trailerErrorMessage = "No YouTube trailer available."
                }
            } catch {
                guard !Task.isCancelled else { return }
                state.trailerErrorMessage = error.localizedDescription
            }

            do {
                let cast = try await castResult
                guard !Task.isCancelled else { return }
                state.cast = cast
            } catch {
                guard !Task.isCancelled else { return }
                state.cast = []
                state.castErrorMessage = error.localizedDescription
            }

            state.isLoading = false
            loadReviews(page: 1, append: false)
        }
    }

    private func loadReviews(page: Int, append: Bool) {
        reviewsTask?.cancel()

        if append {
            state.isLoadingMoreReviews = true
            state.loadMoreReviewsErrorMessage = nil
        } else if state.reviews.isEmpty {
            state.reviewsErrorMessage = nil
        }

        reviewsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await interactor.fetchReviews(id: movieId, page: page)
                guard !Task.isCancelled else { return }

                if append {
                    let existing = Set(state.reviews.map(\.id))
                    let newItems = result.items.filter { !existing.contains($0.id) }
                    state.reviews.append(contentsOf: newItems)
                } else {
                    state.reviews = result.items
                    if result.items.isEmpty {
                        state.reviewsErrorMessage = "No reviews yet."
                    }
                }
                state.reviewsPage = result.page
                state.reviewsTotalPages = result.totalPages
                state.isLoadingMoreReviews = false
            } catch {
                guard !Task.isCancelled else { return }
                if append {
                    state.loadMoreReviewsErrorMessage = error.localizedDescription
                    state.isLoadingMoreReviews = false
                } else {
                    state.reviewsErrorMessage = error.localizedDescription
                }
            }
        }
    }
}
