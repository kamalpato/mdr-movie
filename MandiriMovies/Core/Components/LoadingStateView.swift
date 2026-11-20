import SwiftUI

struct LoadingStateView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack {
            ProgressView()
            Text(message)
                .font(AppTheme.Typography.loading)
                .foregroundStyle(AppTheme.ColorToken.primaryText)
                .padding()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.ColorToken.background)
    }
}
