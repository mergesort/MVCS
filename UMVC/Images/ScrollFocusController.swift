import Combine
import SwiftUI

final class ScrollFocusController<T: Hashable>: ObservableObject {

    private let currentValueSubject = CurrentValueSubject<T?, Never>(nil)

    var publisher: AnyPublisher<T?, Never> {
        return self.currentValueSubject.eraseToAnyPublisher()
    }

    func scrollTo(_ remoteImage: T) {
        self.currentValueSubject.value = remoteImage
        self.currentValueSubject.value = nil
    }

}
