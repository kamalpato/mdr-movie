import SwiftUI

struct InfiniteScrollTrigger: View {
    let isLoadingMore: Bool
    let hasMore: Bool
    let onAppear: () -> Void

    var body: some View {
        Group {
            if hasMore {
                HStack {
                    Spacer()
                    if isLoadingMore {
                        ProgressView()
                    } else {
                        Color.clear.frame(height: 1)
                    }
                    Spacer()
                }
                .frame(height: 44)
                .onAppear(perform: onAppear)
            }
        }
    }
}
