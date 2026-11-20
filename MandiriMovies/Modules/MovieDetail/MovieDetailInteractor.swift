import Foundation

protocol MovieDetailInteractorInterface: InteractorInterface {
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
    func fetchTrailer(id: Int) async throws -> MovieTrailer?
    func fetchCast(id: Int) async throws -> [Actor]
    func fetchReviews(id: Int, page: Int) async throws -> PageResult<MovieReview>
}

final class MovieDetailInteractor: MovieDetailInteractorInterface {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        try await repository.fetchMovieDetail(id: id)
    }

    func fetchTrailer(id: Int) async throws -> MovieTrailer? {
        try await repository.fetchMovieTrailer(id: id)
    }

    func fetchCast(id: Int) async throws -> [Actor] {
        try await repository.fetchActors(movieId: id)
    }

    func fetchReviews(id: Int, page: Int) async throws -> PageResult<MovieReview> {
        try await repository.fetchMovieReviews(id: id, page: page)
    }
}
