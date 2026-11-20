import Foundation

protocol MovieRepositoryProtocol {
    func fetchGenres() async throws -> [Genre]
    func fetchDiscoverMovies(genreID: Int?, page: Int) async throws -> PageResult<Movie>
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
    func fetchMovieReviews(id: Int, page: Int) async throws -> PageResult<MovieReview>
    func fetchMovieTrailer(id: Int) async throws -> MovieTrailer?
    func fetchActors(movieId: Int) async throws -> [Actor]
}

final class MovieRepository: MovieRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func fetchGenres() async throws -> [Genre] {
        let response: GenreListResponseDTO = try await apiClient.request(TMDBEndpoint.genreList())
        let genres = response.genres.map { $0.toDomain() }
        guard !genres.isEmpty else { throw APIError.emptyData }
        return genres
    }

    func fetchDiscoverMovies(genreID: Int?, page: Int) async throws -> PageResult<Movie> {
        let response: PaginatedMoviesResponseDTO = try await apiClient.request(
            TMDBEndpoint.discoverMovies(genreID: genreID, page: page)
        )
        return PageResult(
            items: response.results.map { $0.toDomain() },
            page: response.page,
            totalPages: max(response.totalPages, 1)
        )
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        let dto: MovieDTO = try await apiClient.request(TMDBEndpoint.movieDetail(id: id))
        return dto.toDetailDomain()
    }

    func fetchMovieReviews(id: Int, page: Int) async throws -> PageResult<MovieReview> {
        let response: PaginatedReviewsResponseDTO = try await apiClient.request(
            TMDBEndpoint.movieReviews(id: id, page: page)
        )
        return PageResult(
            items: response.results.map { $0.toDomain() },
            page: response.page,
            totalPages: max(response.totalPages, 1)
        )
    }

    func fetchMovieTrailer(id: Int) async throws -> MovieTrailer? {
        let response: VideosResponseDTO = try await apiClient.request(
            TMDBEndpoint.movieVideos(id: id)
        )
        let trailers = response.results.compactMap { $0.toTrailer() }
        return trailers.first(where: { $0.type == "Trailer" }) ?? trailers.first
    }

    func fetchActors(movieId: Int) async throws -> [Actor] {
        let credits: CreditsDTO = try await apiClient.request(
            TMDBEndpoint.movieCredits(id: movieId)
        )
        let actors = (credits.cast ?? []).prefix(20).map {
            Actor(
                id: $0.id,
                name: $0.name,
                character: $0.character,
                profilePath: $0.profilePath
            )
        }
        guard !actors.isEmpty else { throw APIError.emptyData }
        return Array(actors)
    }
}
