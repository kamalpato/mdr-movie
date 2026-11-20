import SwiftUI

struct RatingView: View {
    let rating: Double
    var maxStars: Int = 5

    private var filledCount: Int {
        RatingMath.filledStarCount(for: rating, maxStars: maxStars)
    }

    var body: some View {
        HStack(spacing: 2) {
            Text(formattedRating)
                .font(AppTheme.Typography.ratingNumber)
                .foregroundStyle(AppTheme.ColorToken.primaryText)

            ForEach(0..<maxStars, id: \.self) { index in
                Image(systemName: index < filledCount ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.ColorToken.rating)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating \(formattedRating) out of 10")
    }

    private var formattedRating: String {
        String(format: "%g", rating)
    }
}
