import Foundation

enum AppConfig {
    static let tmdbBaseURL = URL(string: "https://api.themoviedb.org/3")!
    static let posterImageBase = "https://image.tmdb.org/t/p/w500"
    static let backdropImageBase = "https://image.tmdb.org/t/p/w780"

    static var tmdbAPIKey: String {
        let key = AppSecrets.tmdbAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return key
    }

    static var hasAPIKey: Bool {
        !tmdbAPIKey.isEmpty
    }
}
