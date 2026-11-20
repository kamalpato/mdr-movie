import SwiftUI

struct MovieDetailModuleView: View {
    @ObservedObject var router: AppRouter
    @StateObject private var presenter: MovieDetailPresenter

    init(movie: Movie, router: AppRouter) {
        self.router = router
        _presenter = StateObject(
            wrappedValue: MovieDetailPresenter(
                movie: movie,
                interactor: MovieDetailInteractor(),
                router: router
            )
        )
    }

    var body: some View {
        MovieDetailView(presenter: presenter)
    }
}

enum MovieDetailBuilder {
    @MainActor
    static func build(movie: Movie, router: AppRouter) -> some View {
        MovieDetailModuleView(movie: movie, router: router)
    }
}
