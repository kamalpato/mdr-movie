import Foundation

protocol GenresInteractorInterface: InteractorInterface {
    func fetchGenres() async throws -> [Genre]
}

final class GenresInteractor: GenresInteractorInterface {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func fetchGenres() async throws -> [Genre] {
        try await repository.fetchGenres()
    }
}
