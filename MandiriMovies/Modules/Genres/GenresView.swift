import SwiftUI

struct GenresView: View {
    @ObservedObject var presenter: GenresPresenter

    var body: some View {
        Group {
            if presenter.state.isLoading && !presenter.state.hasContent {
                LoadingStateView(message: "Loading genres…")
            } else if let error = presenter.state.errorMessage, !presenter.state.hasContent {
                ErrorStateView(
                    title: "Unable to load genres",
                    message: error,
                    onRetry: presenter.retry
                )
            } else {
                List(presenter.state.genres) { genre in
                    Button {
                        presenter.didSelectGenre(genre)
                    } label: {
                        HStack {
                            Text(genre.name)
                                .foregroundStyle(AppTheme.ColorToken.primaryText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppTheme.ColorToken.secondaryText)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(AppTheme.ColorToken.background)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable { presenter.retry() }
            }
        }
        .background(AppTheme.ColorToken.background.ignoresSafeArea())
        .navigationTitle("Genres")
        .onAppear { presenter.onAppear() }
    }
}
