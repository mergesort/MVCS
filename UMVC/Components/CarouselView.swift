import SwiftUI

/// A View for displaying content in a horizontally scrolling grid.
struct CarouselView<Item: Identifiable, ContentView: View>: View {

    var items: [Item]
    var contentView: (Item) -> ContentView

    @Environment(\.focusController) private var focusController
    @State private var customPreferenceKey: String = ""

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { reader in
                HStack(alignment: .top, spacing: 16.0) {
                    ForEach(items) { item in
                        contentView(item)
                            .tag(item.id)
                    }
                }
                .onReceive(self.focusController.$focusedImage, perform: { image in
                    if let image = image {
                        withAnimation {
                            reader.scrollTo(image.id)
                        }
                    }
                })
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

}
