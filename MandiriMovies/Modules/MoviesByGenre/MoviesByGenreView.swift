import SwiftUI

struct MoviesByGenreView: View {
    @ObservedObject var presenter: MoviesByGenrePresenter

    var body: some View {
        Group {
            if presenter.state.isLoading && !presenter.state.hasContent {
                LoadingStateView(message: "Loading movies…")
            } else if let error = presenter.state.errorMessage, !presenter.state.hasContent {
                ErrorStateView(
                    title: "Unable to load movies",
                    message: error,
                    onRetry: presenter.retry
                )
            } else {
                List {
                    ForEach(presenter.state.movies) { movie in
                        Button {
                            presenter.didSelectMovie(movie)
                        } label: {
                            MovieRowView(movie: movie)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(AppTheme.ColorToken.background)
                    }

                    if let loadMoreError = presenter.state.loadMoreErrorMessage {
                        Text(loadMoreError)
                            .font(AppTheme.Typography.sectionLabel)
                            .foregroundStyle(.red)
                            .onAppear { presenter.loadNextPageIfNeeded() }
                    }

                    InfiniteScrollTrigger(
                        isLoadingMore: presenter.state.isLoadingMore,
                        hasMore: presenter.state.hasMore
                    ) {
                        presenter.loadNextPageIfNeeded()
                    }
                    .listRowBackground(AppTheme.ColorToken.background)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable { presenter.retry() }
            }
        }
        .background(AppTheme.ColorToken.background.ignoresSafeArea())
        .navigationTitle(presenter.state.genre.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { presenter.onAppear() }
    }
}
