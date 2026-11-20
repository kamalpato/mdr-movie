import SwiftUI

struct MovieDetailView: View {
    @ObservedObject var presenter: MovieDetailPresenter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                if presenter.state.isLoading && presenter.state.detail == nil && presenter.state.movie == nil {
                    LoadingStateView(message: "Loading detail…")
                        .frame(minHeight: 280)
                } else if let error = presenter.state.errorMessage, presenter.state.movie == nil {
                    ErrorStateView(
                        title: "Unable to load",
                        message: error,
                        onRetry: presenter.retry
                    )
                } else {
                    headerSection
                    primaryInfoSection
                    castSection
                    trailerSection
                    reviewsSection
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .background(AppTheme.ColorToken.background.ignoresSafeArea())
        .navigationTitle(presenter.state.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear { presenter.onAppear() }
    }

    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImageView(url: presenter.state.displayBackdropURL, contentMode: .fill)
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            HStack(alignment: .bottom, spacing: 12) {
                MoviePosterImage(
                    url: presenter.state.displayPosterURL,
                    width: 96,
                    height: 144
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(presenter.state.displayTitle)
                        .font(AppTheme.Typography.detailTitle)
                        .foregroundStyle(.white)
                        .lineLimit(3)

                    if let releaseDate = presenter.state.displayReleaseDate {
                        Text(releaseDate)
                            .font(AppTheme.Typography.sectionLabel)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
            .padding(12)
        }
    }

    private var primaryInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let tagline = presenter.state.displayTagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.callout.italic())
                    .foregroundStyle(AppTheme.ColorToken.secondaryText)
            }

            RatingView(rating: presenter.state.displayRating)
                .frame(maxWidth: .infinity, alignment: .leading)

            if presenter.state.displayVoteCount > 0 {
                Text("\(presenter.state.displayVoteCount) votes")
                    .font(AppTheme.Typography.sectionLabel)
                    .foregroundStyle(AppTheme.ColorToken.secondaryText)
            }

            if let runtime = presenter.state.displayRuntime {
                Text("\(runtime) min")
                    .font(AppTheme.Typography.sectionLabel)
                    .foregroundStyle(AppTheme.ColorToken.secondaryText)
            }

            GenreChipsView(genres: presenter.state.displayGenres)

            Text(presenter.state.displayOverview)
                .font(.body)
                .foregroundStyle(AppTheme.ColorToken.primaryText)
        }
    }

    private var castSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cast")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.ColorToken.primaryText)

            if presenter.state.cast.isEmpty {
                Text(presenter.state.castErrorMessage ?? "Loading cast…")
                    .font(AppTheme.Typography.sectionLabel)
                    .foregroundStyle(AppTheme.ColorToken.secondaryText)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        ForEach(presenter.state.cast) { actor in
                            VStack(spacing: 6) {
                                MoviePosterImage(
                                    url: actor.profileURL,
                                    width: 72,
                                    height: 108
                                )

                                Text(actor.name)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.ColorToken.primaryText)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 72)

                                if let character = actor.character, !character.isEmpty {
                                    Text(character)
                                        .font(.caption2)
                                        .foregroundStyle(AppTheme.ColorToken.secondaryText)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 72)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var trailerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trailer")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.ColorToken.primaryText)

            if let trailer = presenter.state.trailer {
                YouTubeTrailerCard(trailer: trailer)
            } else if let message = presenter.state.trailerErrorMessage {
                Text(message)
                    .font(AppTheme.Typography.sectionLabel)
                    .foregroundStyle(AppTheme.ColorToken.secondaryText)
            } else if presenter.state.isLoading {
                ProgressView()
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("User Reviews")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.ColorToken.primaryText)

            if presenter.state.reviews.isEmpty {
                if let message = presenter.state.reviewsErrorMessage {
                    Text(message)
                        .font(AppTheme.Typography.sectionLabel)
                        .foregroundStyle(AppTheme.ColorToken.secondaryText)
                } else {
                    ProgressView()
                }
            } else {
                ForEach(presenter.state.reviews) { review in
                    ReviewCardView(review: review)
                }

                if let loadMoreError = presenter.state.loadMoreReviewsErrorMessage {
                    Text(loadMoreError)
                        .font(AppTheme.Typography.sectionLabel)
                        .foregroundStyle(.red)
                }

                InfiniteScrollTrigger(
                    isLoadingMore: presenter.state.isLoadingMoreReviews,
                    hasMore: presenter.state.hasMoreReviews
                ) {
                    presenter.loadMoreReviewsIfNeeded()
                }
            }
        }
    }
}
