import SwiftUI

@MainActor
open class BaseRouter<Route: Hashable>: ObservableObject, RouterInterface {
    @Published public var path = NavigationPath()

    public init() {}

    public func navigate(to route: Route) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }
}
