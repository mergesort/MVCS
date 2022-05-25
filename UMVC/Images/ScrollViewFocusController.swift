import SwiftUI

final class ScrollFocusController: ObservableObject {
    @Published var focusedImage: RemoteImage?
}

private extension ScrollFocusController {
    static let `default` = ScrollFocusController()
}

// MARK: Environment

private struct ScrollFocusControllerEnvironmentKey: EnvironmentKey {
    static let defaultValue = ScrollFocusController.default
}

extension EnvironmentValues {
    var focusController: ScrollFocusController {
        get {
            return self[ScrollFocusControllerEnvironmentKey.self]
        }
        set {
            self[ScrollFocusControllerEnvironmentKey.self] = newValue
        }
    }
}
