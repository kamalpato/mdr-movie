import SwiftUI

struct RemoteImageView: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var placeholderSystemName: String = "film"

    var body: some View {
        CachedRemoteImageContent(
            url: url,
            contentMode: contentMode,
            placeholderSystemName: placeholderSystemName
        )
        .id(url?.absoluteString ?? "nil")
    }
}

private struct CachedRemoteImageContent: View {
    let contentMode: ContentMode
    let placeholderSystemName: String

    @StateObject private var loader: ImageLoader

    init(
        url: URL?,
        contentMode: ContentMode,
        placeholderSystemName: String
    ) {
        self.contentMode = contentMode
        self.placeholderSystemName = placeholderSystemName
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
            } else {
                Color.secondary.opacity(0.12)
                Image(systemName: placeholderSystemName)
                    .font(.title2)
                    .foregroundStyle(AppTheme.ColorToken.secondaryText)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .onAppear { loader.load() }
    }
}
