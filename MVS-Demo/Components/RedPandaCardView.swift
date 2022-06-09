import Boutique
import SwiftUI

/// A view that fetches a red panda image from the server and allows a user to favorite the red panda.
struct RedPandaCardView: View {

    @EnvironmentObject private var focusController: ScrollFocusController<String>

    // An instance of `ImagesController`, which can take in the shared store or another store if we so choose,
    // an important part of our Controllers being decoupled from our Stores.
//    @StateObject private var imagesController = ImagesController()
    @StateObject private var imagesController = ImagesController(store: Store.imagesStore)

    @State private var currentImage: RemoteImage?

    var body: some View {
        VStack(spacing: 16.0) {
            if let currentImage = currentImage {
                Spacer()

                RemoteImageView(image: currentImage)
//                    .frame(maxHeight: 300.0)
                    .frame(maxWidth: 300.0)
//                    .frame(width: 300.0)
                    .frame(height: 300.0)
                //, height: 300.0)
//                    .clipped()
//                    .centerCroppedCardStyle()
                    .aspectRatio(CGFloat(currentImage.height / currentImage.width), contentMode: .fit)
                    .shadow(color: .black, radius: 2.0, x: 1.0, y: 1.0)
                    .overlay(content: {
                        if self.currentImageIsSaved {
                            Color.black.opacity(0.5)
                        } else {
                            Color.clear
                        }
                    })
                    .onTapGesture(perform: {
                        if self.currentImageIsSaved {
                            focusController.scrollTo(self.currentImage!.id)
                        }
                    })
            } else {
                ProgressView()
                    .frame(width: 300.0, height: 300.0)
            }

            VStack(spacing: 0.0) {
                Button(action: {
                    Task {
                        try await self.fetchImage()
                    }
                }, label: {
                    Label("Fetch", systemImage: "arrow.clockwise.circle")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52.0)
                        .background(Color.palette.primary)
                        .foregroundColor(.white)
                })

                Button(action: {
                    Task {
                        if self.currentImageIsSaved {
                            focusController.scrollTo(self.currentImage!.id)
                        } else {
                            try await self.imagesController.saveImage(image: self.currentImage!)
                            try await self.fetchImage()
                        }
                    }
                }, label: {
                    let title = self.currentImageIsSaved ? "View Favorite" : "Favorite"
                    let imageName = self.currentImageIsSaved ? "star.circle.fill" : "star.circle"
                    Label(title, systemImage: imageName)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52.0)
                        .background(self.currentImageIsSaved ? Color.palette.secondary : Color.palette.tertiary)
                        .foregroundColor(.white)
                })
            }
            .cornerRadius(8.0)
        }
        .padding(.vertical, 16.0)
        .task({
            do {
                try await self.fetchImage()
            } catch {
                print("Error fetching image", error)
            }
        })
    }

}

private extension RedPandaCardView {

    func fetchImage() async throws {
        self.currentImage = nil // Assigning nil shows the progress spinner
        self.currentImage = try await self.imagesController.fetchImage()
    }

    var currentImageIsSaved: Bool {
        if let image = self.currentImage {
            return self.imagesController.images.contains(where: { image.id == $0.id })
        } else {
            return false
        }
    }

}
