/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The Image cache.
*/
import UIKit
import Foundation

public actor ImageCacheActor {

    enum LoadingError: Error {
        case badImageData
    }

    static let publicCache = ImageCacheActor()
    static let placeholderImage = UIImage(systemName: "rectangle")!
    static let brokenImage = UIImage(systemName: "rectangle.slash")!

    /// This isn't exactly Sendable so we'll see!
    @MainActor
    private let cachedImages = NSCache<NSURL, UIImage>()
    /// This replaces the dictionary that had the closure returning the item and UIImage when complete.
    /// Instead, we'll hold the tasks that we can cancel if we need to.
    private var loadingResponses = [URL: Task<(UIImage), any Error>]()

    @MainActor
    public final func image(url: URL) -> UIImage? {
        return cachedImages.object(forKey: url as NSURL)
    }

    /// - Tag: cache
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    final func load(url: URL) async throws -> UIImage {
        // Why the defer? The task will hold on to the value so let's nil that out and let the cache do it's job.
        defer { loadingResponses.removeValue(forKey: url) }
        // Check for a cached image.
        if let cachedImage = await image(url: url) {
            return cachedImage
        }
        // In case there are more than one requestor for the image, we wait for the previous request and
        // return the image (or throw)
        if let previousTask = loadingResponses[url] {
            return try await previousTask.value
        }

        // Go fetch the image.
        let currentTask = Task {
            let (data, _) = try await ImageURLAsyncProtocol.urlSession().data(from: url)
            // Try to create the image. If not, throw bad image data error.
            guard let image = UIImage(data: data) else {
                throw LoadingError.badImageData
            }
            // Cache the image.
            await setCachedImage(image, atUrl: url)
            return image
        }
        // We will save the Task in case another request comes for the same URL.
        loadingResponses[url] = currentTask
        return try await currentTask.value
    }

    @MainActor
    private func setCachedImage(_ cachedImage: UIImage, atUrl url: URL) {
        cachedImages.setObject(cachedImage, forKey: url as NSURL)
    }
}
