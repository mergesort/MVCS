import Boutique
import SwiftUI

/// A view that fetches a red panda image from the server and allows a user to favorite the red panda.
struct RedPandaCardView: View {

    @EnvironmentObject private var focusController: ScrollFocusController<String>

    @StateObject private var imagesController = ImagesController()

    @State private var currentImage: RemoteImage?

    @State private var requestInFlight = false

    var body: some View {
        VStack(spacing: 16.0) {
            if let currentImage = currentImage {
                Spacer()

                RemoteImageView(image: currentImage)
                    .aspectRatio(CGFloat(currentImage.width / currentImage.height), contentMode: .fit)
                    .primaryBorder()
                    .overlay(content: {
                        if self.currentImageIsSaved {
                            Color.black.opacity(0.5)
                        } else {
                            Color.clear
                        }
                    })
                    .cornerRadius(8.0)
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
                        try await self.setCurrentImage()
                    }
                }, label: {
                    Label("Fetch", systemImage: "arrow.clockwise.circle")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52.0)
                        .background(Color.palette.primary.overlay(self.requestInFlight ? Color.black.opacity(0.2) : Color.clear))
                        .foregroundColor(.white)
                })
                .disabled(self.requestInFlight)

                Button(action: {
                    Task {
                        if self.currentImageIsSaved {
                            focusController.scrollTo(self.currentImage!.id)
                        } else {
                            try await self.imagesController.saveImage(image: self.currentImage!)
                            try await self.setCurrentImage()
                        }
                    }
                }, label: {
                    let title = self.currentImageIsSaved ? "View Favorite" : "Favorite"
                    let imageName = self.currentImageIsSaved ? "star.circle.fill" : "star.circle"
                    Label(title, systemImage: imageName)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52.0)
                        .background(
                            // I wouldn't use AnyView in a production app, but too lazy to disambiguate the required types here
                            self.currentImageIsSaved ?
                                AnyView(Color.palette.secondary) :
                                AnyView(Color.palette.tertiary.overlay(self.requestInFlight ? Color.black.opacity(0.2) : Color.clear))
                        )
                        .foregroundColor(.white)
                })
                .disabled(self.requestInFlight)
            }
            .cornerRadius(8.0)
        }
        .padding(.vertical, 16.0)
        .task({
            do {
                try await self.setCurrentImage()
            } catch {
                print("Error fetching image", error)
            }
        })
    }

}

private extension RedPandaCardView {

    func setCurrentImage() async throws {
        self.requestInFlight = true
        defer {
            self.requestInFlight = false
        }

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
