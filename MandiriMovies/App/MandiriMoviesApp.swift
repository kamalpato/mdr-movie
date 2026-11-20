import SwiftUI

@main
struct MandiriMoviesApp: App {
    init() {
        ImageURLCacheConfigurator.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRouterView()
                .preferredColorScheme(.light)
                .tint(AppTheme.ColorToken.tabActive)
        }
    }
}
