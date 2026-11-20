import SwiftUI

struct MoviePosterImage: View {
    let url: URL?
    var width: CGFloat? = nil
    var height: CGFloat? = nil

    var body: some View {
        RemoteImageView(url: url)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.poster, style: .continuous))
    }
}
