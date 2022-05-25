import SwiftUI

extension View {

    func centerCroppedCardStyle() -> some View {
        self
            .scaledToFill()
            .clipped()
            .cornerRadius(8.0)
    }

}
