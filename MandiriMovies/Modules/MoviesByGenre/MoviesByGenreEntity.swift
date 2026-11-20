import Foundation

struct MoviesByGenreViewState: Equatable {
    var genre: Genre
    var movies: [Movie] = []
    var currentPage = 0
    var totalPages = 1
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var loadMoreErrorMessage: String?

    var hasContent: Bool { !movies.isEmpty }
    var hasMore: Bool { currentPage < totalPages }
}
