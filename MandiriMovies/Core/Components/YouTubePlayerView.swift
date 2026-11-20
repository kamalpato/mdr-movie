import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoKey: String
    var onError: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(onError: onError)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webpagePrefs = WKWebpagePreferences()
        webpagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webpagePrefs

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.layer.cornerRadius = 12
        webView.clipsToBounds = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.onError = onError
        guard context.coordinator.loadedKey != videoKey else { return }
        context.coordinator.loadedKey = videoKey

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
          <style>
            html, body { margin: 0; padding: 0; background: #000; height: 100%; overflow: hidden; }
            .wrap { position: absolute; inset: 0; }
            iframe { width: 100%; height: 100%; border: 0; }
          </style>
        </head>
        <body>
          <div class="wrap">
            <iframe
              src="https://www.youtube-nocookie.com/embed/\(videoKey)?playsinline=1&rel=0&modestbranding=1&controls=1"
              title="YouTube trailer"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
              allowfullscreen
              referrerpolicy="strict-origin-when-cross-origin">
            </iframe>
          </div>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var loadedKey: String?
        var onError: (() -> Void)?

        init(onError: (() -> Void)?) {
            self.onError = onError
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            onError?()
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            onError?()
        }
    }
}

struct YouTubeTrailerCard: View {
    let trailer: MovieTrailer
    @State private var playerFailed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if playerFailed {
                fallback
            } else {
                YouTubePlayerView(videoKey: trailer.key) {
                    playerFailed = true
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Text(trailer.name)
                .font(AppTheme.Typography.sectionLabel)
                .foregroundStyle(AppTheme.ColorToken.secondaryText)

            if let url = trailer.youtubeURL {
                Link("Open in YouTube", destination: url)
                    .font(AppTheme.Typography.sectionLabel)
            }
        }
    }

    private var fallback: some View {
        ZStack {
            RemoteImageView(
                url: URL(string: "https://img.youtube.com/vi/\(trailer.key)/hqdefault.jpg"),
                contentMode: .fill
            )
            .frame(height: 220)
            .clipped()

            Color.black.opacity(0.35)

            if let url = trailer.youtubeURL {
                Link(destination: url) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
