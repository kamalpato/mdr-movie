import Foundation
@testable import MandiriMovies

final class MockMovieRepository: MovieRepositoryProtocol {
    var genresResult: Result<[Genre], Error> = .success([])
    var discoverResult: Result<PageResult<Movie>, Error> = .success(
        PageResult(items: [], page: 1, totalPages: 1)
    )
    var detailResult: Result<MovieDetail, Error> = .failure(APIError.invalidResponse)
    var reviewsResult: Result<PageResult<MovieReview>, Error> = .success(
        PageResult(items: [], page: 1, totalPages: 1)
    )
    var trailerResult: Result<MovieTrailer?, Error> = .success(nil)
    var actorsResult: Result<[Actor], Error> = .failure(APIError.emptyData)

    private(set) var discoverPagesRequested: [Int] = []
    private(set) var reviewPagesRequested: [Int] = []

    func fetchGenres() async throws -> [Genre] {
        try genresResult.get()
    }

    func fetchDiscoverMovies(genreID: Int?, page: Int) async throws -> PageResult<Movie> {
        discoverPagesRequested.append(page)
        return try discoverResult.get()
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        try detailResult.get()
    }

    func fetchMovieReviews(id: Int, page: Int) async throws -> PageResult<MovieReview> {
        reviewPagesRequested.append(page)
        return try reviewsResult.get()
    }

    func fetchMovieTrailer(id: Int) async throws -> MovieTrailer? {
        try trailerResult.get()
    }

    func fetchActors(movieId: Int) async throws -> [Actor] {
        try actorsResult.get()
    }
}

final class MockGenresInteractor: GenresInteractorInterface {
    var result: Result<[Genre], Error>

    init(result: Result<[Genre], Error>) {
        self.result = result
    }

    func fetchGenres() async throws -> [Genre] {
        try result.get()
    }
}

final class MockMoviesByGenreInteractor: MoviesByGenreInteractorInterface {
    var pages: [Int: Result<PageResult<Movie>, Error>] = [:]
    private(set) var requestedPages: [Int] = []

    func fetchMovies(genreID: Int, page: Int) async throws -> PageResult<Movie> {
        requestedPages.append(page)
        guard let result = pages[page] else {
            throw APIError.emptyData
        }
        return try result.get()
    }
}

final class MockMovieDetailInteractor: MovieDetailInteractorInterface {
    var detailResult: Result<MovieDetail, Error>
    var trailerResult: Result<MovieTrailer?, Error>
    var castResult: Result<[Actor], Error>
    var reviewPages: [Int: Result<PageResult<MovieReview>, Error>]
    private(set) var requestedReviewPages: [Int] = []
    private(set) var requestedCastMovieIds: [Int] = []

    init(
        detailResult: Result<MovieDetail, Error>,
        trailerResult: Result<MovieTrailer?, Error> = .success(nil),
        castResult: Result<[Actor], Error> = .success([]),
        reviewPages: [Int: Result<PageResult<MovieReview>, Error>] = [:]
    ) {
        self.detailResult = detailResult
        self.trailerResult = trailerResult
        self.castResult = castResult
        self.reviewPages = reviewPages
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        try detailResult.get()
    }

    func fetchTrailer(id: Int) async throws -> MovieTrailer? {
        try trailerResult.get()
    }

    func fetchCast(id: Int) async throws -> [Actor] {
        requestedCastMovieIds.append(id)
        return try castResult.get()
    }

    func fetchReviews(id: Int, page: Int) async throws -> PageResult<MovieReview> {
        requestedReviewPages.append(page)
        guard let result = reviewPages[page] else {
            throw APIError.emptyData
        }
        return try result.get()
    }
}
