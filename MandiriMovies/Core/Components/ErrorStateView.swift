import SwiftUI

struct ErrorStateView: View {
    var title: String = "Something went wrong"
    var message: String
    var imageName: String? = "Error"
    var retryTitle: String? = "Retry"
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.poster))
            } else {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            }

            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.ColorToken.primaryText)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.ColorToken.secondaryText)
                .multilineTextAlignment(.center)

            if let retryTitle, let onRetry {
                Button(retryTitle, action: onRetry)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppTheme.ColorToken.background)
    }
}
