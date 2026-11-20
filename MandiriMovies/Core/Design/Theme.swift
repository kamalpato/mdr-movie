import SwiftUI

enum AppTheme {
    enum ColorToken {
        static let background = Color.white
        static let cardBackground = Color.white
        static let primaryText = Color.black
        static let secondaryText = Color(white: 0.35)
        static let rating = Color(red: 1.0, green: 0.39, blue: 0.28)
        static let genreBorder = Color(white: 0.8)
        static let genreText = Color.black.opacity(0.4)
        static let backdropScrimTop = Color.black.opacity(0)
        static let backdropScrimBottom = Color.white
        static let tabActive = Color.blue
        static let tabInactive = Color(red: 0.678, green: 0.710, blue: 0.741)
    }

    enum Typography {
        static let cardTitle = Font.system(size: 24, weight: .regular)
        static let body = Font.system(size: 12, weight: .regular)
        static let ratingNumber = Font.system(size: 14, weight: .regular)
        static let genre = Font.system(size: 9, weight: .regular)
        static let loading = Font.system(size: 18, weight: .bold)
        static let detailTitle = Font.system(size: 22, weight: .semibold)
        static let sectionLabel = Font.system(size: 12, weight: .regular)
    }

    enum Radius {
        static let card: CGFloat = 34
        static let poster: CGFloat = 24
        static let genre: CGFloat = 14
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 20
        static let lg: CGFloat = 30
    }
}
