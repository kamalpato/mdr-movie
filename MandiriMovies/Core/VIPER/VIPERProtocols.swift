import Foundation
import SwiftUI

protocol ViewInterface: AnyObject {}

protocol InteractorInterface: AnyObject {}

protocol PresenterInterface: ObservableObject {}

protocol EntityInterface {}

protocol RouterInterface: AnyObject {
    associatedtype Route: Hashable
    var path: NavigationPath { get set }
    func navigate(to route: Route)
    func pop()
    func popToRoot()
}

protocol ModuleBuilder {
    associatedtype Content: View
    static func build() -> Content
}
