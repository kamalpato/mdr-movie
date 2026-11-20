import SwiftUI

struct GenresModuleView: View {
    @ObservedObject var router: AppRouter
    @StateObject private var presenter: GenresPresenter

    init(router: AppRouter) {
        self.router = router
        _presenter = StateObject(
            wrappedValue: GenresPresenter(
                interactor: GenresInteractor(),
                router: router
            )
        )
    }

    var body: some View {
        GenresView(presenter: presenter)
    }
}

enum GenresBuilder {
    @MainActor
    static func build(router: AppRouter) -> some View {
        GenresModuleView(router: router)
    }
}
