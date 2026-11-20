import Foundation

protocol GenresPresenterInterface: PresenterInterface {
    var state: GenresViewState { get }
    func onAppear()
    func retry()
    func didSelectGenre(_ genre: Genre)
}

@MainActor
final class GenresPresenter: GenresPresenterInterface {
    @Published private(set) var state = GenresViewState()

    private let interactor: GenresInteractorInterface
    private weak var router: AppRouter?
    private var loadTask: Task<Void, Never>?

    init(interactor: GenresInteractorInterface, router: AppRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onAppear() {
        guard !state.hasContent, !state.isLoading else { return }
        load()
    }

    func retry() {
        load()
    }

    func didSelectGenre(_ genre: Genre) {
        router?.navigate(to: .moviesByGenre(genre))
    }

    private func load() {
        loadTask?.cancel()
        state.isLoading = true
        state.errorMessage = nil

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let genres = try await interactor.fetchGenres()
                guard !Task.isCancelled else { return }
                state.genres = genres
                state.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                state.errorMessage = error.localizedDescription
                state.isLoading = false
            }
        }
    }
}
