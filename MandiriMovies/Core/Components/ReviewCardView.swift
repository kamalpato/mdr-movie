import SwiftUI

struct ReviewCardView: View {
    let review: MovieReview

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.author)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ColorToken.primaryText)

                Spacer()

                if let rating = review.rating {
                    Text(String(format: "%.1f/10", rating))
                        .font(AppTheme.Typography.sectionLabel)
                        .foregroundStyle(AppTheme.ColorToken.rating)
                }
            }

            if let createdAt = review.createdAt {
                Text(createdAt)
                    .font(.caption)
                    .foregroundStyle(AppTheme.ColorToken.secondaryText)
            }

            Text(review.content)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.ColorToken.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
