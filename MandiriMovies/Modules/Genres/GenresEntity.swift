import Foundation

struct GenresViewState: Equatable {
    var genres: [Genre] = []
    var isLoading = false
    var errorMessage: String?

    var hasContent: Bool { !genres.isEmpty }
}
