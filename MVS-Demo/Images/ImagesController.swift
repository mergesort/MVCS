import Boutique
import Foundation
import SwiftUI

// Model View Observable Object
// MVCS
// MVS
// use this in views rather than view models

/// A controller that allows you to fetch, save, and delete images from a `Store`.
final class ImagesController: ObservableObject {

//    @Stored(in: Store.imagesStore) var images
    @Stored var images: [RemoteImage]

    init(store: Store<RemoteImage>) {
        self._images = Stored(in: store)
    }

    /// Fetches `RemoteImage` from the API, providing the user with a red panda if the request suceeds.
    /// - Returns: The `RemoteImage` requested.
    func fetchImage() async throws -> RemoteImage {
        // Hit the API that provides you a random image's metadata
        let imageURL = URL(string: "https://image.redpanda.club/random/json")!
        let randomImageRequest = URLRequest(url: imageURL)
        let (randomImageJSONData, _) = try await URLSession.shared.data(for: randomImageRequest)

        let imageResponse = try JSONDecoder().decode(RemoteImageResponse.self, from: randomImageJSONData)

        // Download the image at the URL we received from the API
        let imageRequest = URLRequest(url: imageResponse.url)
        let (imageData, _) = try await URLSession.shared.data(for: imageRequest)

        // Lazy error handling, sorry, please do it better in your app
        guard let pngData = UIImage(data: imageData)?.pngData() else { throw DownloadError.badData }

        return RemoteImage(createdAt: .now, url: imageResponse.url, width: imageResponse.width, height: imageResponse.height, dataRepresentation: pngData)
    }

    /// Saves an image to the `Store` in memory and on disk.
    /// - Parameter image: A `RemoteImage` to be saved.
    func saveImage(image: RemoteImage) async throws {
        try await self.$images.add(image)
    }

    /// Removes one image from the `Store` in memory and on disk.
    /// - Parameter image: A `RemoteImage` to be removed.
    func removeImage(image: RemoteImage) async throws {
        try await self.$images.remove(image)
    }

    /// Removes all of the images from the `Store` in memory and on disk.
    func clearAllImages() async throws {
        try await self.$images.removeAll()
    }

}

extension ImagesController {

    /// A few simple errors we can throw in case we receive bad data.
    enum DownloadError: Error {
        case badData
        case unexpectedStatusCode
    }

}

private extension ImagesController {

    /// A type representing the API response providing image metadata from the API we're interacting with.
    struct RemoteImageResponse: Codable {
        let height: Float
        let width: Float
        let key: String
        let url: URL
    }

}
