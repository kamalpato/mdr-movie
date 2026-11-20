import SwiftUI

struct MoviesByGenreModuleView: View {
    @ObservedObject var router: AppRouter
    @StateObject private var presenter: MoviesByGenrePresenter

    init(genre: Genre, router: AppRouter) {
        self.router = router
        _presenter = StateObject(
            wrappedValue: MoviesByGenrePresenter(
                genre: genre,
                interactor: MoviesByGenreInteractor(),
                router: router
            )
        )
    }

    var body: some View {
        MoviesByGenreView(presenter: presenter)
    }
}

enum MoviesByGenreBuilder {
    @MainActor
    static func build(genre: Genre, router: AppRouter) -> some View {
        MoviesByGenreModuleView(genre: genre, router: router)
    }
}
