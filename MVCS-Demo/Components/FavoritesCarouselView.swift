import Boutique
import SwiftUI

// Below you'll see code that looks like this.
// CarouselView(
//    items: self.images,
//    contentView: { image in
//      ...
//    }
// )
//
// In place of `self.images` you may be tempted to directly use `imagesController.images`.
// That will likely be fine for views rendering a small amount of data, especially if you
// read the data directly (as opposed to performing operations such as map, filter, sort, etc).
// But as the data grows this will create a performance bottleneck.
//
// The reason for this bottleneck is related to SwiftUI, and how SwiftUI renders Views.
// The body of a SwiftUI is recomputed often, and you don't know when they're going to recompute.
// It can happen any time, but because SwiftUI Views are simple structs rendering and recomputing
// is not computationally expensive. What that means though is that imagesController.images will
// be recalculated every render, and that can be computationally expensive,
// especially if you apply operations like map, filter, sort, or have a large data set.
//
// But if you store the result of imagesController.images in a `@State` var, it will no longer
// be recomputed on every render. That's because `@State` provides reference semantics
// to the var, `self.images, that allow `self.images` to be persisted across View renders.
// That turns an expensive operation into minimal cost since there are
// no longer any computations occurring on re-render.

// That's a long way of saying if you're working with a large data set or would like
// to do more complex transforms on imagesController.images it's worth remembering
// that you can subscribe to the @Published property your controller exposes.
// This approach is probably worth using as your default, especially if you
// don't know how large your array will be.
//
// Here `ImagesController`'s `images` is a @Published property which you can store and manipulate
// in your own `@State` property by subscribing to self.imagesController.$images.$items like so.
//
//    @State private var images: [RemoteImage] = []
//
//    .onReceive(self.imagesController.$images.$items, perform: {
//        self.images = $0.filter({ $0.width > 500 && $0.height > 500 })
//    })


/// A horizontally scrolling carousel that displays the red panda images a user has favorited.
struct FavoritesCarouselView: View {

    @StateObject private var imagesController = ImagesController()

    @State private var animation: Animation? = nil
    @State private var images: [RemoteImage] = []

    var body: some View {
        VStack {
            HStack {
                Text("Favorites")
                    .bold()
                    .font(.largeTitle)
                    .padding(.top)

                Spacer()

                Button(action: {
                    Task {
                        try await imagesController.clearAllImages()
                    }
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .opacity(imagesController.images.isEmpty ? 0.0 : 1.0)
                        .font(.title)
                        .foregroundColor(.red)
                })
            }

            if self.imagesController.images.isEmpty {
                VStack {
                    Spacer()

                    Text("Add some red pandas you love and they'll appear here!")
                        .multilineTextAlignment(.center)
                        .font(.title)

                    Spacer()
                }
            } else {
                HStack {
                    CarouselView(
                        items: self.images,
                        contentView: { image in
                            ZStack(alignment: .topTrailing) {
                                RemoteImageView(image: image)
                                    .primaryBorder()
                                    .centerCroppedCardStyle()

                                Button(action: {
                                    Task {
                                        try await self.imagesController.removeImage(image: image)
                                    }
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .shadow(color: .primary, radius: 4.0, x: 2.0, y: 2.0)
                                })
                                .padding(8.0)
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))
                    .animation(animation, value: self.imagesController.images)
                }
                .task({
                    // Too lazy to figure out how to not trigger the janky
                    // initial animation because it's mostly irrelevant to this demo.
                    try! await Task.sleep(nanoseconds: 100_000_000)
                    self.animation = .easeInOut(duration: 0.35)
                })
            }
        }
        .onReceive(self.imagesController.$images.$items, perform: {
            self.images = $0.sorted(by: { $0.createdAt > $1.createdAt})
        })
        .frame(height: 200.0)
        .background(Color.palette.background)
    }

}
