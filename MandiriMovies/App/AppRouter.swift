import SwiftUI

enum AppRoute: Hashable {
    case moviesByGenre(Genre)
    case movieDetail(Movie)
}

@MainActor
final class AppRouter: BaseRouter<AppRoute> {}

struct AppRouterView: View {
    @StateObject private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            GenresBuilder.build(router: router)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .moviesByGenre(let genre):
                        MoviesByGenreBuilder.build(genre: genre, router: router)
                    case .movieDetail(let movie):
                        MovieDetailBuilder.build(movie: movie, router: router)
                    }
                }
        }
        .tint(AppTheme.ColorToken.tabActive)
    }
}
