/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The Image cache.
*/
import Foundation
import UIKit

public actor ImageCache {

    enum LoadingError: Error {
        case badImageData
    }

    static let publicCache = ImageCache()

    let placeholderImage = UIImage(systemName: "rectangle")!
    let brokenImage = UIImage(systemName: "rectangle.slash")!

    /// This isn't exactly Sendable so we'll see!
    private let cachedImages = NSCache<NSURL, UIImage>()
    /// This replaces the dictionary that had the closure returning the item and UIImage when complete.
    /// Instead, we'll hold the tasks that we can cancel if we need to.
    private var loadingResponses = [URL: Task<(UIImage), any Error>]()

    public final func image(url: URL) -> UIImage? {
        return cachedImages.object(forKey: url as NSURL)
    }

    /// - Tag: cache
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    final func load(url: URL) async throws -> UIImage {
        // Check for a cached image.
        if let cachedImage = image(url: url) {
            return cachedImage
        }
        // In case there are more than one requestor for the image, we wait for the previous request and
        // return the image (or throw)
        if let previousTask = loadingResponses[url] {
            return try await previousTask.value
        }

        // Go fetch the image.
        let currentTask = Task {
            // TODO: JVO update ImageURLProtocol with modern version.
            let (data, _) = try await ImageURLProtocol.urlSession().data(from: url)
            // Try to create the image. If not, throw bad image data error.
            guard let image = UIImage(data: data) else {
                throw LoadingError.badImageData
            }
            // Cache the image.
            cachedImages.setObject(image, forKey: url as NSURL, cost: data.count)
            return image
        }
        // We will save the Task in case another request comes for the same URL.
        loadingResponses[url] = currentTask
        return try await currentTask.value
    }
}
