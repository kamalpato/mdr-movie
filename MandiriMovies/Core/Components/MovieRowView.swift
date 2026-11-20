import SwiftUI

struct MovieRowView: View {
    let movie: Movie

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            MoviePosterImage(url: movie.posterURL, width: 72, height: 108)

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ColorToken.primaryText)
                    .lineLimit(2)

                if let releaseDate = movie.releaseDate {
                    Text(releaseDate)
                        .font(AppTheme.Typography.sectionLabel)
                        .foregroundStyle(AppTheme.ColorToken.secondaryText)
                }

                RatingView(rating: movie.voteAverage)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(movie.overview)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.ColorToken.secondaryText)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }
}
