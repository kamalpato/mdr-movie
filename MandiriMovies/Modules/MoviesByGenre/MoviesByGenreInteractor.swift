import Foundation

protocol MoviesByGenreInteractorInterface: InteractorInterface {
    func fetchMovies(genreID: Int, page: Int) async throws -> PageResult<Movie>
}

final class MoviesByGenreInteractor: MoviesByGenreInteractorInterface {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func fetchMovies(genreID: Int, page: Int) async throws -> PageResult<Movie> {
        try await repository.fetchDiscoverMovies(genreID: genreID, page: page)
    }
}
