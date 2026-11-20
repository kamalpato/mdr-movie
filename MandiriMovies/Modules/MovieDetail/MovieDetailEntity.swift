import Foundation

struct MovieDetailViewState: Equatable {
    var movie: Movie?
    var detail: MovieDetail?
    var trailer: MovieTrailer?
    var cast: [Actor] = []
    var reviews: [MovieReview] = []
    var reviewsPage = 0
    var reviewsTotalPages = 1
    var isLoading = false
    var isLoadingMoreReviews = false
    var errorMessage: String?
    var trailerErrorMessage: String?
    var castErrorMessage: String?
    var reviewsErrorMessage: String?
    var loadMoreReviewsErrorMessage: String?

    var hasMoreReviews: Bool { reviewsPage < reviewsTotalPages }

    var displayTitle: String { detail?.title ?? movie?.title ?? "" }
    var displayOverview: String { detail?.overview ?? movie?.overview ?? "" }
    var displayReleaseDate: String? { detail?.releaseDate ?? movie?.releaseDate }
    var displayRating: Double { detail?.voteAverage ?? movie?.voteAverage ?? 0 }
    var displayGenres: [String] {
        if let detail, !detail.genreNames.isEmpty { return detail.genreNames }
        return movie?.genreNames ?? []
    }
    var displayPosterURL: URL? { detail?.posterURL ?? movie?.posterURL }
    var displayBackdropURL: URL? { detail?.backdropURL ?? movie?.backdropURL }
    var displayRuntime: Int? { detail?.runtimeMinutes }
    var displayTagline: String? { detail?.tagline }
    var displayVoteCount: Int { detail?.voteCount ?? 0 }
}
