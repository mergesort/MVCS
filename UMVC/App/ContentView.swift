import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack(spacing: 0.0) {
            FavoritesCarouselView()
                .padding(.bottom, 8.0)

            Divider()

            Spacer()

            RedPandaCardView()
        }
        .padding(.horizontal, 16.0)
        .background(Color.palette.background)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
